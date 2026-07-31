{
  pkgs,
  config,
  lib,
  modules,
  ...
}:
with lib;
let
  cfg = config.modules.lxqt;
in
{
  imports = with modules; [
    iwd
    xorg
    brightnessctl
    lxqt
  ];

  options.modules.lxqt = {
    enable = mkEnableOption "lxqt";

    enableXorg = lib.mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable lxqt xorg session
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.lxqt.enable = true;
    programs.lxqt.xsession.enable = cfg.enableXorg;
    programs.lxqt.iconTheme = pkgs.papirus-icon-theme;
    programs.xorg.enable = cfg.enableXorg;
    programs.lxqt.extraPackages = with pkgs; [
      # core breeze qt theme
      kdePackages.breeze
      kdePackages.breeze-icons
      kdePackages.breeze-gtk
      kdePackages.qttools
      kdePackages.ark
      hicolor-icon-theme
      labwc-tweaks
      lxqt-panel-profiles
      labwc-gtktheme
    ];

    services.dbus.packages = with pkgs; [
      tumbler
      dconf
      xfconf
    ];

    xdg.portal.portals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
