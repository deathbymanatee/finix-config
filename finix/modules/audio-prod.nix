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
    enable = mkEnableOption "Audio production stack";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      reaper
      # https://github.com/reaper-oss/sws/wiki/Installing-the-SWS-Extension-(for-end-users)/
      reaper-sws-extension

      # wine64 also???
      winePackages.yabridge
      yabridgectl

      pkgs.easyeffects
      pkgs.calf
      pkgs.qjackctl
    ];
  };
}
