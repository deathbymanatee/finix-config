{
  lib,
  pkgs,
  config,
  ...
}:

with lib;

let
  cfg = config.programs.initviz;
  pkg = pkgs.callPackage ./package.nix { };
in
{
  options.programs.initviz = {
    enable = mkEnableOption "initviz";
    package = mkOption {
      type = types.package;
      default = pkg;
      defaultText = "pkgs.initviz";
      description = "The Pipewire package to use.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
