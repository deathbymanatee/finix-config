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
  ];

  # Use latest kernel.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "loglevel=1" ];
  };

  finit = {
    runlevel = 3;
    services.nix-daemon = {
      environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
    };
  };

  networking.hostName = "home-desktop"; # Define your hostname.

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  services = {
    polkit.enable = true;
    sysklogd.enable = true;
    dbus.enable = true;
    dhcpcd.enable = true;
    openssh.enable = true;
    seatd.enable = true;
    mdevd = {
      enable = true;
      nlgroups = 4;
    };
    rtkit.enable = true;
    rtkit.extraGroups = [ config.services.seatd.group ];

    lemurs = {
      enable = true;
      # TODO make pr that codes this path as the default since this is where all the other WMs dump their desktop entries
      settings = {
        wayland.wayland_sessions_path = lib.mkForce "/run/current-system/sw/share/wayland-sessions";
        x11.xsessions_path = lib.mkForce "/run/current-system/sw/share/xsessions";
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

    flatpak.enable = true;
    flatpak.extraGroups = [ config.services.seatd.group ];
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
  # coincidentally this issue also prevents nixos from asking for a root password after installation
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
      "render"
      config.services.seatd.group
    ];
  };

  providers.privileges.rules = lib.optionals config.services.mdevd.enable [
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

  # custom modules
  modules = {
    packages.enable = true;
    # sway = {
    #   enable = true;
    #   user = "ryan";
    # };
    lxqt = {
      enable = true;
      user = "ryan";
    };
    pipewire.enable = true;
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
