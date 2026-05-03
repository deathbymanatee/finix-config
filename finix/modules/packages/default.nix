{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.packages;
  maintenance = pkgs.writeShellScriptBin "maintenance" "${builtins.readFile ./maintenance}";
  rebuild = pkgs.writeShellScriptBin "rebuild" "${builtins.readFile ./rebuild}";

in
{
  options.modules.packages = {
    enable = mkEnableOption "packages";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      maintenance
      rebuild
    ];
  };
}
