{
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "virt-manager"; # Define your hostname.

  services.lemurs.enable = true;
  services.iwd.enable = true;
  services.iwd.enableEad = true;

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
      "render"
      # comment out if using elogind
      config.services.seatd.group
    ];
  };

  # custom modules
  modules = {
    packages.enable = true;
    lxqt.enable = true;
    lxqt.user = "ryan";
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
    inxi
  ];
}
