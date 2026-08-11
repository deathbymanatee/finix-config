{
  pkgs,
  config,
  lib,
  modules,
  ...
}:
with lib;
let
  cfg = config.modules.labwc;
in
{
  imports = with modules; [
    labwc
    pmount
  ];

  options.modules.labwc = {
    enable = mkEnableOption "labwc";
  };

  config = lib.mkIf cfg.enable {
    programs.labwc.enable = true;
    programs.pmount.enable = true;

    environment.systemPackages = with pkgs; [
      kdePackages.breeze
      kdePackages.breeze-icons
      kdePackages.breeze-gtk
      kdePackages.qttools
      kdePackages.ark
      hicolor-icon-theme
      papirus-icon-theme
      thunar
      thunar-volman
      thunar-archive-plugin
      labwc-tweaks
      labwc-gtktheme
      nwg-look
      qt6Packages.qt6ct
    ];

    services.dbus.packages = with pkgs; [
      thunar-volman
      thunar-archive-plugin
      xfconf
    ];

    # TODO xdg.mime.defaultApplications and xdg.mime.addedAssociations
  };

}
