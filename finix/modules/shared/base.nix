{
  config,
  pkgs,
  lib,
  modules,
  inputs,
  ...
}:
let
  communityModules = with inputs.community-modules.nixosModules; [
    pipewire
  ];
in
{
  imports =
    with modules;
    [
      nix-daemon
      upower
      openssh
      sysklogd
      limine
      sudo
      getty
      bash
      iwd
      dhcpcd
      lemurs
      flatpak
      polkit
      sway
      xwayland-satellite
      rtkit
      lxqt
      zzz
      fwupd
      xserver
      brightnessctl
      ly
      pmount
      docker
    ]
    ++ communityModules;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;

  finit.runlevel = 3;
  finit.services = {
    nix-daemon.environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
  };
  finit.cgroups.system.settings = {
    "cpu.weight" = 100;
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # system services
  services.sysklogd.enable = true;
  services.polkit.enable = true;
  services.dbus.enable = true;
  services.dhcpcd.enable = true; # enable iwd for wireless
  services.openssh.enable = true;
  services.upower.enable = true;
  services.rtkit.enable = true;
  services.seatd.enable = true;
  services.rtkit.extraGroups = [ config.services.seatd.group ];
  services.gardendevd.enable = true;
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
  services.mdevd = {
    enable = true;
    nlgroups = 4;
    # debug = true;
  };
  services.mdevd.hotplugRules = lib.mkIf config.services.mdevd.enable (
    lib.mkAfter ''
      grsec       root:root 660
      kmem        root:root 640
      mem         root:root 640
      port        root:root 640
      console     root:tty 600 @chmod 600 $MDEV
      card[0-9]   root:video 660 =dri/

      event[0-9]+ root:input 660 =input/
      mice        root:input 660 =input/
      mouse[0-9]+ root:input 660 =input/

      rfkill      root:${config.services.seatd.group} 660
    ''
  );

  # required workaround to get /dev/disk/by-uuid/* mounts to work with mdevd
  # https://github.com/finix-community/finix/issues/67#issuecomment-4491668055
  boot.initrd.fileSystemImportCommands = lib.mkOrder 499 ''
    sleep 2

    mkdir -p /dev/disk/by-label /dev/disk/by-uuid
    current_dev=""
    blkid --output export | while IFS='=' read -r key value; do
      case "$key" in
        DEVNAME)
          current_dev="$value"
          ;;
        LABEL)
          [ -n "$current_dev" ] || continue
          ln -snf "$current_dev" "/dev/disk/by-label/$value"
          ;;
        UUID)
          [ -n "$current_dev" ] || continue
          ln -snf "$current_dev" "/dev/disk/by-uuid/$value"
          ;;
      esac
    done

    # extra debug output
    # ls -l /dev/disk/by-uuid
    # blkid --output export
  '';

  # system programs
  programs.sudo.enable = true;
  programs.bash.enable = true;
  programs.resolvconf.enable = true;
  # programs.initviz.enable = true;
  programs.limine = {
    enable = true;
    settings.editor_enabled = true;
  };

  # still requires sudo poweroff, cannot use org.freedesktop power commands in graphical environments
  providers.privileges.rules = lib.optionals config.services.seatd.enable [
    {
      command = "/run/current-system/sw/bin/poweroff";
      groups = [ config.services.seatd.group ];
      requirePassword = false;
    }
    {
      command = "/run/current-system/sw/bin/reboot";
      groups = [ config.services.seatd.group ];
      requirePassword = false;
    }
  ];

  security.pam.environment.NIX_PATH.default = "nixpkgs=${pkgs.path}";

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    nixos-rebuild-ng
    iputils
    iproute2
    cargo
    gcc
    man
    fastfetch
    ripgrep
    ncdu
    nix-init
  ];
}
