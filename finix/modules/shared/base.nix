{
  config,
  pkgs,
  lib,
  modules,
  ...
}:
{
  imports = with modules; [
    nix-daemon
    openssh
    sysklogd
    limine
    sudo
    getty
    bash
    iwd
    resolvconf
    lemurs
    flatpak
    sway
    xwayland-satellite
    rtkit
    lxqt
    zzz
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "loglevel=1" ];

  finit.runlevel = 3;
  finit.services = {
    nix-daemon.environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
  };

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # system services
  services.sysklogd.enable = true;
  services.polkit.enable = true;
  services.dbus.enable = true;
  services.iwd.enable = true;
  services.openssh.enable = true;
  services.upower.enable = true;
  services.rtkit.enable = true;
  services.rtkit.extraGroups = [ config.services.seatd.group ];
  services.lemurs = {
    enable = true;
    settings = {
      wayland.wayland_sessions_path = lib.mkForce "/run/current-system/sw/share/wayland-sessions";
      x11.xsessions_path = lib.mkForce "/run/current-system/sw/share/xsessions";
    };
  };
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
  };

  # system programs
  programs.sudo.enable = true;
  programs.bash.enable = true;
  programs.resolvconf.enable = true;
  programs.limine = {
    enable = true;
    settings.editor_enabled = true;
  };

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
    # base
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
  ];
}
