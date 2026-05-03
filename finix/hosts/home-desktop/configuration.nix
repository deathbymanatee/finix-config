{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules
  ];

  boot = {
    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages_latest;
    loader.efi.canTouchEfiVariables = true;
  };

  finit = {
    runlevel = 3;
    services.nix-daemon = {
      environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
    };
  };

  services = {
    nix-daemon = {
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

    polkit.enable = true;
    elogind.enable = true;
    sysklogd.enable = true;
    dbus.enable = true;
    udev.enable = true;
    dhcpcd.enable = true;
    flatpak.enable = true;
    cups.enable = true;
  };

  networking.hostName = "home-desktop"; # Define your hostname.

  # install graphics stuff
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  programs = {
    limine = {
      enable = true;
      settings.editor_enabled = true; # Disable on systems that need security
      force = true;
    };

    sudo.enable = true;
    bash.enable = true;

    lemurs = {
      enable = true;
      settings = {
        wayland.wayland_sessions_path = lib.mkForce "/run/current-system/sw/share/wayland-sessions";
      };
    };

    # TODO: keep an eye on https://github.com/finix-community/finix/tree/modules/plasma
    plasma.enable = true;
  };

  # enable custom packages in modules/packages
  packages.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ryan = {
    isNormalUser = true;
    description = "test user";
    extraGroups = [
      "wheel"
      "input"
      "audio"
      "video"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # base packages
    neovim
    wget
    git
    nixos-rebuild-ng
    iputils
    iproute2
    cargo
    gcc

    # gui
    keepassxc
    steam
    steam.run
    protonup-qt
    librewolf

    # audio
    pipewire
    wireplumber
    qpwgraph
    reaper
    winePackages.yabridge
  ];

}
