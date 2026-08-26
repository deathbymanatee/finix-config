# legcord rebuild with patched pipewire for (hopefully) better screenshare performance
{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.legcord;

in
{
  options.modules.legcord = {
    enable = mkEnableOption "legcord";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.legcord
    ];
  };
}
