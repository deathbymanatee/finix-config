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
    services.gardendevd.enable = true;
    services.rtkit.enable = true;
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
      man
      fastfetch
      ncdu
    ];
  };
}
