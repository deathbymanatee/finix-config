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
    environment.systemPackages = with pkgs; [
      steam
      steam-run
      protonup-qt
      gamescope
    ];
  };
}
