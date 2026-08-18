/*
  minimal, shared, base configuration. using this alone will only get you a TTY and
  wired newtorking with dhcpcd + nftables service.
*/
{
  config,
  pkgs,
  modules,
  lib,
  ...
}:
let
  cfg = config.configs.base;

in
{
  imports = with modules; [
    nix-daemon
    upower
    openssh
    sysklogd
    limine
    sudo
    getty
    bash
    rtkit
    dhcpcd
    nftables
  ];

  options.configs.base = {
    enable = lib.mkEnableOption "base";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.efi.canTouchEfiVariables = true;

    finit.services = {
      nix-daemon.environment.CURL_CA_BUNDLE = config.security.pki.caBundle;
    };
    finit.cgroups.system.settings = {
      "cpu.weight" = 100;
    };

    services.sysklogd.enable = true;
    services.openssh.enable = true;
    services.udev.enable = true;
    services.rtkit.enable = true;
    services.dhcpcd.enable = true;
    services.nftables.enable = true;
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

    # sets NIX_PATH env variable for ad hoc nix shells
    security.pam.environment.NIX_PATH.default = "nixpkgs=${pkgs.path}";

    # builds `maintenance` and `rebuild` commands
    modules.custom-packages.enable = true;

    environment.systemPackages = with pkgs; [
      neovim
      wget
      git
      nixos-rebuild-ng
      man
      fastfetch
      ncdu
      iputils
      iproute2
    ];
  };
}
