{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

with lib;
let
  cfg = config.modules.steam;
  communityModules = with inputs.community-modules.nixosModules; [
    steam
  ];
in
{
  imports = communityModules;
  options.modules.steam = {
    enable = mkEnableOption "steam";
  };

  config = mkIf cfg.enable {

    programs.steam.enable = true;
    programs.steam.extraPackages = [
      pkgs.kdePackages.breeze
      pkgs.kdePackages.breeze-icons
      pkgs.kdePackages.breeze-gtk
    ];

    environment.systemPackages = with pkgs; [
      protonup-qt
    ];
  };
}
