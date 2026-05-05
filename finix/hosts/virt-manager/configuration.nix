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

  # Use latest kernel.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.efi.canTouchEfiVariables = true;
  };

  finit = {
    runlevel = 3;
    services.nix-daemon = {
      environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
    };
  };

  networking.hostName = "virt-manager"; # Define your hostname.

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  services = {
    polkit.enable = true;
    sysklogd.enable = true;
    dbus.enable = true;
    dhcpcd.enable = true;
    openssh.enable = true;

    # udev doesn't work for luks... or anything else really
    # mdevd.enable = true;
    udev.enable = true;

    lemurs = {
      enable = true;
      # TODO make pr that codes this path as the default since this is where all the other WMs dump their desktop entries
      settings = {
        wayland.wayland_sessions_path = lib.mkForce "/run/current-system/sw/share/wayland-sessions";
      };
    };
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
  };

  programs = {
    # boot loader
    limine = {
      enable = true;
      settings.editor_enabled = true; # Disable on systems that need security
      force = true;
    };

    sudo.enable = true;
    bash.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # trying to do nixos-enter 'passwd' will result in 'command passwd not found' so we need to do something different for initial account setup.
  # you will need to include a password hash here on first setup. example:
  # `password = "some password hash";`
  # generate this hash with: `mkpasswd -m sha-512 password`
  # don't commit the password hash to git for the love of god
  # this issue will probably be fixed later
  users.users.ryan = {
    isNormalUser = true;
    description = "test user";
    extraGroups = [
      "wheel"
      "input"
      "audio"
      "video"
      "power"
      # remove if using elogind
      # config.services.seatd.group
    ];
  };

  # custom modules
  modules = {
    packages.enable = true;
    # sway = {
    #   enable = true;
    #   user = "ryan";
    # };
    plasma.enable = true;
  };

  # base packages
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

    # lagniappe
    fastfetch
    ripgrep
    btop
  ];
}
