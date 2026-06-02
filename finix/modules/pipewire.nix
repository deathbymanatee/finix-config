{
  lib,
  config,
  pkgs,
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

    environment.systemPackages = with pkgs; [
      easyeffects
      calf
      qpwgraph
    ];
  };
}
