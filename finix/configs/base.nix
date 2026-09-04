/*
  minimal, shared, base configuration. using this alone will only get you a TTY and
  wired newtorking with dhcpcd + nftables service + chronyd.
*/
{
  config,
  pkgs,
  modules,
  lib,
  ...
}:
let
  cfg = config.configs.base;
  keepassxc = pkgs.symlinkJoin {
    name = "keepassxc-x11-desktop";
    paths = [ pkgs.keepassxc ];
    # Use postBuild to overwrite the desktop entry inside this symlink tree
    postBuild = ''
      rm -f $out/share/applications/org.keepassxc.KeePassXC.desktop
      mkdir -p $out/share/applications
      cat <<EOF > $out/share/applications/org.keepassxc.KeePassXC.desktop
      [Desktop Entry]
      Name=KeePassXC
      GenericName=Password Manager
      Exec=keepassxc -platform xcb %f
      Icon=keepassxc
      Terminal=false
      Type=Application
      Version=1.0
      Categories=Utility;Security;
      MimeType=application/x-keepass2;
      StartupWMClass=keepassxc
      EOF
    '';
  };
  neovim-fhs =
    {
      buildFHSEnv,
      writeShellScript,
      neovim,
    }:
    buildFHSEnv {
      name = "nvim-fhs";
      targetPkgs = pkgs: [ neovim ];

      runScript = writeShellScript "nvim-fhs.sh" ''
        exec ${neovim}/bin/nvim "$@"
      '';
    };

in
{
  imports = with modules; [
    nix-daemon
    upower
    openssh
    sysklogd
    limine
    sudo
    getty
    bash
    rtkit
    dhcpcd
    nftables
    chronyd
    anacron
  ];

  options.configs.base = {
    enable = lib.mkEnableOption "base";

    dotfileManagement = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "User to chown dotfiles to";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.efi.canTouchEfiVariables = true;

    finit.services = {
      nix-daemon.environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
    };
    finit.cgroups.system.settings = {
      "cpu.weight" = 100;
    };

    services.sysklogd.enable = true;
    services.openssh.enable = true;
    services.rtkit.enable = true;
    services.dhcpcd.enable = true;
    services.nftables.enable = true;
    services.chrony.enable = true;
    services.getty.enable = true;
    services.anacron.enable = true;
    services.nix-daemon = {
      enable = true;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };

    programs.sudo.enable = true;
    programs.bash.enable = true;
    programs.limine.enable = true;
    programs.limine.settings.editor_enabled = true;

    # sets NIX_PATH env variable for ad hoc nix shells
    security.pam.environment.NIX_PATH.default = "nixpkgs=${pkgs.path}";

    # builds `maintenance` and `rebuild` commands
    modules.custom-packages.enable = true;

    environment.systemPackages =
      with pkgs;
      # https://wiki.nixos.org/wiki/Neovim#Troubleshooting
      [
        (pkgs.callPackage neovim-fhs { })
        wget
        git
        nixos-rebuild-ng
        man
        ncdu
        iputils
        iproute2
        bzip2
        cpio
        curl
        diffutils
        gzip
        xz
        netcat
        mkpasswd
        zstd
        gnupatch
        gnused
        gnutar
        keepassxc
        pciutils
        glib
        usbutils
      ];
  };
}
