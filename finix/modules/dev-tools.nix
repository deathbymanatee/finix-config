{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.dev-tools;

in
{
  options.modules.dev-tools = {
    enable = mkEnableOption "dev-tools";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cargo
      gcc
      ripgrep
      nix-init
      strace
      perl
      unzip
      zip
      gnumake
      python314
    ];
  };
}
