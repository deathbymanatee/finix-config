{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.steam;

in
{
  options.modules.steam = {
    enable = mkEnableOption "steam";
  };
  config = mkIf cfg.enable {

    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    environment.systemPackages = with pkgs; [
      steam
      steam-run
      protonup-qt
      gamescope
    ];
  };
}
