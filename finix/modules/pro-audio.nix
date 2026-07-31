{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.pro-audio;

in
{
  options.modules.pro-audio = {
    enable = mkEnableOption "Audio production stack";
  };
  config = mkIf cfg.enable {
    programs.pipewire.enable = true;
    programs.pipewire.jack.enable = true;
    programs.pipewire.alsa.enable = true;
    programs.wireplumber.enable = true;

    programs.pipewire = {
      settings = {
        "10-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 256;
            "default.clock.min-quantum" = 256;
            "default.clock.max-quantum" = 512;
          };
        };
      };
      jack.settings = {
        "12-jack-low-latency" = {
          "jack.properties" = {
            "node.latency" = "256/48000";
          };
        };
      };
    };

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
