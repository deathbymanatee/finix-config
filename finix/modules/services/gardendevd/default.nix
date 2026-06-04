{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.gardendevd;

  gardendevd = pkgs.callPackage ./package.nix { };

  # Udev has a 512-character limit for ENV{PATH}, so create a symlink
  # tree to work around this.
  udevPath = pkgs.buildEnv {
    name = "udev-path";
    paths = cfg.path;
    pathsToLink = [
      "/bin"
      "/sbin"
    ];
    ignoreCollisions = true;
  };

  # Perform substitutions in all udev rules files.
  udevRulesFor =
    {
      name,
      udevPackages,
      udevPath,
      udev,
      binPackages,
    }:
    pkgs.runCommand name
      {
        preferLocalBuild = true;
        allowSubstitutes = false;
        packages = lib.unique (map toString udevPackages);
      }
      ''
        mkdir -p $out
        shopt -s nullglob
        set +o pipefail

        # Set a reasonable $PATH for programs called by udev rules.
        echo 'ENV{PATH}="${udevPath}/bin:${udevPath}/sbin"' > $out/00-path.rules

        # Add the udev rules from other packages.
        for i in $packages; do
          echo "Adding rules for package $i"
          for j in $i/{etc,lib,var/lib}/udev/rules.d/*; do
            echo "Copying $j to $out/$(basename $j)"
            cat $j > $out/$(basename $j)
          done
        done

        # Fix some paths in the standard udev rules.  Hacky.
        for i in $out/*.rules; do
          substituteInPlace $i \
            --replace-quiet \"/sbin/modprobe \"${pkgs.kmod}/bin/modprobe \
            --replace-quiet \"/sbin/mdadm \"${pkgs.mdadm}/sbin/mdadm \
            --replace-quiet \"/sbin/blkid \"${pkgs.util-linux}/sbin/blkid \
            --replace-quiet \"/bin/mount \"${pkgs.util-linux}/bin/mount \
            --replace-quiet /usr/bin/readlink ${pkgs.coreutils}/bin/readlink \
            --replace-quiet /usr/bin/cat ${pkgs.coreutils}/bin/cat \
            --replace-quiet /usr/bin/basename ${pkgs.coreutils}/bin/basename 2>/dev/null
        done

        echo -n "Checking that all programs called by relative paths in udev rules exist in ${udev}/lib/udev... "
        import_progs=$(grep 'IMPORT{program}="[^/$]' $out/* |
          sed -e 's/.*IMPORT{program}="\([^ "]*\)[ "].*/\1/' | uniq)
        run_progs=$(grep -v '^[[:space:]]*#' $out/* | grep 'RUN+="[^/$]' |
          sed -e 's/.*RUN+="\([^ "]*\)[ "].*/\1/' | uniq)
        for i in $import_progs $run_progs; do
          if [[ ! -x ${udev}/lib/udev/$i && ! $i =~ socket:.* ]]; then
            echo "FAIL"
            echo "$i is called in udev rules but not installed by udev"
            exit 1
          fi
        done
        echo "OK"

        echo -n "Checking that all programs called by absolute paths in udev rules exist... "
        import_progs=$(grep 'IMPORT{program}="/' $out/* |
          sed -e 's/.*IMPORT{program}="\([^ "]*\)[ "].*/\1/' | uniq)
        run_progs=$(grep -v '^[[:space:]]*#' $out/* | grep 'RUN+="/' |
          sed -e 's/.*RUN+="\([^ "]*\)[ "].*/\1/' | uniq)
        for i in $import_progs $run_progs; do
          if [[ ! -x $i ]]; then
            echo "FAIL"
            echo "$i is called in udev rules but is not executable or does not exist"
            exit 1
          fi
        done
        echo "OK"

        filesToFixup="$(for i in "$out"/*; do
          # list all files referring to (/usr)/bin paths, but allow references to /bin/sh.
          grep -P -l '\B(?!\/bin\/sh\b)(\/usr)?\/bin(?:\/.*)?' "$i" || :
        done)"

        if [ -n "$filesToFixup" ]; then
          echo "Consider fixing the following udev rules:"
          echo "$filesToFixup" | while read localFile; do
            remoteFile="origin unknown"
            for i in ${toString binPackages}; do
              for j in "$i"/*/udev/rules.d/*; do
                [ -e "$out/$(basename "$j")" ] || continue
                [ "$(basename "$j")" = "$(basename "$localFile")" ] || continue
                remoteFile="originally from $j"
                break 2
              done
            done
            refs="$(
              grep -o '\B\(/usr\)\?/s\?bin/[^ "]\+' "$localFile" \
                | sed -e ':r;N;''${s/\n/ and /;br};s/\n/, /g;br'
            )"
            echo "$localFile ($remoteFile) contains references to $refs."
          done
          exit 1
        fi
      '';

in
{
  options.services.gardendevd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable [gardendevd](${gardendevd.meta.homepage}) as a system service.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = gardendevd;
      defaultText = lib.literalExpression "pkgs.gardendevd";
      description = ''
        The package to use for `gardendevd`.
      '';
    };

    udevPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.eudev;
      defaultText = lib.literalExpression "pkgs.eudev";
      description = ''
        The package to use for `eudev`.
      '';
    };

    udevPackages = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      description = ''
        List of packages containing {command}`udev` rules.
        All files found in
        {file}`«pkg»/etc/udev/rules.d` and
        {file}`«pkg»/lib/udev/rules.d`
        will be included.
      '';
      apply = map lib.getBin;
    };

    # TODO: -K flag and maybe -d flag?
    # Or just extra flags section

    log-level = lib.mkOption {
      type = lib.types.enum [
        "debug"
        "info"
        "warning"
        "error"
      ];
      default = "info";
      example = "warning";
      description = ''
        Log level
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc."udev/rules.d".source = udevRulesFor {
      name = "udev-rules";
      udevPackages = cfg.packages;
      binPackages = cfg.packages;
      udev = cfg.udevPackage;

      inherit udevPath;
    };

    services.mdevd.nlgroups = lib.mkForce 2;

    finit.services.gardendevd = {
      description = "udev daemon running on top of mdevd to replace systemd-udev";
      command = "${cfg.package}/bin/gardendevd -v " + lib.toString cfg.log-level;
      conditions = "service/mdevd/ready";
      log = true;
    };
  };
}
