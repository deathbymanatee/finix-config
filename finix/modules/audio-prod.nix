{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.audioProd;

in
{
  options.modules.audioProd = {
    enable = mkEnableOption "audioProd";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      reaper
      winePackages.yabridge
      yabridgectl
      reaper-sws-extension
    ];
  };
}
