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
    package = mkPackageOption pkg;
  };
  config.programs.initviz = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
