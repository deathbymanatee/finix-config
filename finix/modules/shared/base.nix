{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = with inputs.finix.nixosModules; [
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
    tuigreet
    greetd
    pmount
  ];

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

  # required workaround to get /dev/disk/by-uuid/* mounts to work
  # https://github.com/finix-community/finix/issues/67#issuecomment-4491668055
  boot.initrd.fileSystemImportCommands = lib.mkOrder 499 ''
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
  '';

  # system programs
  programs.sudo.enable = true;
  programs.bash.enable = true;
  programs.resolvconf.enable = true;
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
  ];
}
