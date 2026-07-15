# minimal, shared, base configuration
# this will get you a TTY but that's it. everything else should be defined somewhere else
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
    cups
  ];
in
{
  imports =
    with modules;
    [
      pipewire
      nix-daemon
      upower
      openssh
      sysklogd
      limine
      sudo
      getty
      bash
      iwd
      networkmanager
      dhcpcd
      lemurs
      flatpak
      polkit
      sway
      xwayland-satellite
      rtkit
      zzz
      fwupd
      xorg
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

  services.sysklogd.enable = true;
  services.polkit.enable = true;
  services.dbus.enable = true;
  services.dhcpcd.enable = true;
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
  # services.gardendevd.enable = true;
  services.udev.enable = true;

  programs.sudo.enable = true;
  programs.bash.enable = true;
  # programs.resolvconf.enable = true;
  programs.limine = {
    enable = true;
    settings.editor_enabled = true;
  };

  # requires sudo
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
    strace
    perl
    unzip
    zip
  ];
}
