/*
  minimal, shared, base configuration. using this alone will only get you a TTY.

  TODO

    1. move session managers to host configs maybe?
    2. move network services to host configs maybe?
    3. import less stuff in here? only import in places where needed
*/
{
  config,
  pkgs,
  lib,
  modules,
  inputs,
  ...
}:
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
  services.openssh.enable = true;
  services.upower.enable = true;
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

  programs.sudo.enable = true;
  programs.bash.enable = true;
  programs.limine.enable = true;
  programs.limine.settings.editor_enabled = true;

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
