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
      steam.override
      ({
        extraPkgs = [
          pkgs.kdePackages.breeze
          pkgs.kdePackages.breeze-icons
          pkgs.kdePackages.breeze-gtk
        ];
      })
      steam-run
      protonup-qt
      gamescope
    ];
  };
}
