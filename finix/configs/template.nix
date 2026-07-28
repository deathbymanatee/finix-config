{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.configs.CONFIG;

in
{
  options.configs.CONFIG = {
    enable = mkEnableOption "CONFIG";
  };
  config = mkIf cfg.enable {

  };
}
