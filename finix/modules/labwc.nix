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
  fix-gtk-buttons = pkgs.writeShellScriptBin "fix-gtk-buttons" ''
    dconf write /org/gnome/desktop/wm/preferences/button-layout '":minimize,maximize,close"'
  '';
in
{
  imports = with modules; [
    labwc
    pmount
    ./staging/services/gvfs.nix
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
      papirus-icon-theme
      thunar
      thunar-volman
      thunar-archive-plugin
      labwc-tweaks
      labwc-gtktheme
      nwg-look
      qt6Packages.qt6ct
      libnotify
      wlopm
      dconf
      xfconf
      gsettings-desktop-schemas
      fix-gtk-buttons
    ];

    services.gvfs.enable = true;
    services.gvfs.debug = true;
    services.dbus.packages = with pkgs; [
      thunar-volman
      thunar-archive-plugin
      xfconf
    ];

    # gvfs polkit shenanigans
    services.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
          if ((subject.isInGroup("disk") || subject.isInGroup("storage")) &&
              (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
               action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
               action.id == "org.freedesktop.udisks2.filesystem-unmount-others" ||
               action.id == "org.freedesktop.udisks2.eject-media" ||
               action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
               action.id == "org.freedesktop.udisks2.power-off-drive")) {
              return polkit.Result.YES;
          }
      });
    '';

    users.groups.storage = { };

    # TODO xdg.mime.defaultApplications and xdg.mime.addedAssociations
  };

}
