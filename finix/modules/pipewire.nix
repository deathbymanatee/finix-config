{
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.pipewire;

in
{
  options.modules.pipewire = {
    enable = mkEnableOption "pipewire";
  };
  config = mkIf cfg.enable {
    programs.pipewire.enable = true;
  };
}
