{
  config,
  pkgs,
  modules,
  inputs,
  ...
}:
let
  communityModules = with inputs.community-modules.nixosModules; [
    cups
    bootchart
  ];
in
{
  imports =
    with modules;
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      iwd
      dhcpcd
      flatpak
      docker
      brightnessctl
      power-profiles-daemon
    ]
    ++ communityModules;

  configs.graphical-wlroots.enable = true;
  configs.graphical-wlroots.withNoctalia = true;

  services.iwd.enable = true;
  services.docker.enable = true;
  services.cups.enable = true;
  services.upower.enable = true;
  services.udev.enable = true;
  services.flatpak.enable = true;
  services.bootchart.enable = true;
  services.bootchart.stop.conditions = [ "service/ly/ready" ];
  services.flatpak.extraGroups = [ config.services.seatd.group ];
  services.power-profiles-daemon.enable = true;
  services.power-profiles-daemon.extraGroups = [
    config.services.seatd.group
  ];

  programs.brightnessctl.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # custom modules
  modules.pipewire.enable = true;
  modules.labwc.enable = true;
  modules.dev-tools.enable = true;

  /*
    trying to do nixos-enter 'passwd' will result in 'command passwd not found',
    so we need to do something different for initial account setup.
    you will need to include a password hash here on first setup. example:
    `password = "some password hash";`
    generate this hash with: `mkpasswd -m sha-512 password`
    don't commit the password hash to git for the love of god
    this issue will probably be fixed later
  */
  users.users.ryan = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "audio"
      "video"
      "render"
      "tty"
      "docker"
      "storage"
      # comment out if using elogind
      config.services.seatd.group
    ];
  };

  configs.base.dotfileManagement.user = "ryan";

  # extra packages
  environment.systemPackages = with pkgs; [
    # lagniappe
    btop-rocm
    inxi
    libva-utils
    xterm

    keepassxc
    librewolf-bin
    impala
    libreoffice
  ];
}
