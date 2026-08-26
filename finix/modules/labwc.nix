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
  dots-user = config.configs.base.dotfileManagement.user;
in
{
  imports = with modules; [
    labwc
    pmount
    gvfs
  ];

  options.modules.labwc = {
    enable = mkEnableOption "labwc";
  };

  config = lib.mkIf cfg.enable {
    programs.labwc.enable = true;
    programs.pmount.enable = true;

    environment.systemPackages = with pkgs; [
      # desktop utilities
      kdePackages.breeze
      kdePackages.breeze-icons
      kdePackages.breeze-gtk
      kdePackages.qttools
      kdePackages.ark
      kdePackages.okular
      kdePackages.gwenview
      vlc
      thunar
      thunar-volman
      thunar-archive-plugin

      # appearance
      papirus-icon-theme
      labwc-tweaks
      labwc-gtktheme
      nwg-look
      qt6Packages.qt6ct
      dconf
      xfconf
      gsettings-desktop-schemas
      fix-gtk-buttons
    ];

    services.gvfs.enable = true;
    services.dbus.packages = with pkgs; [
      thunar-volman
      thunar-archive-plugin
      xfconf
    ];

    # gvfs polkit shenanigans
    services.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((subject.isInGroup("disk") || subject.isInGroup("storage")) &&
          (
            action.id == "org.freedesktop.udisks2.filesystem-mount" ||
            action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
            action.id == "org.freedesktop.udisks2.filesystem-unmount-others" ||
            action.id == "org.freedesktop.udisks2.eject-media" ||
            action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
            action.id == "org.freedesktop.udisks2.power-off-drive")
          ) {
          return polkit.Result.YES;
        }
      });
    '';

    system.activation.scripts.dotfiles = lib.stringAfter [ "users" ] (''
      home=/home/${dots-user}
      assets_dir=$home/.config/finix-config/finix/modules/assets

      ln -sf -r $assets_dir/labwc/noctalia-shell/labwc $home/.config
      chown ${dots-user} $home/.config/labwc/ -R

      ln -sf -r $assets_dir/wallpapers/ $home/Pictures/Wallpapers
      chown ${dots-user} $home/Pictures/Wallpapers/ -R

      ln -sf -r $assets_dir/way-displays/ $home/.config
      chown ${dots-user} $home/.config/way-displays/ -R

      ln -sf -r $assets_dir/labwc/noctalia-shell/noctalia $home/.config
      chown ${dots-user} $home/.config/noctalia/ -R
    '');

    # ++ lib.optionalString (config.configs.graphical-wlroots.enableNoctalia) (''
    #   ln -sf -r $assets_dir/noctalia/ $home_dir/.config
    #   chown ${dots-user} $home/.config/noctalia/ -R
    # '');

    users.groups.storage = { };

    # TODO xdg.mime.defaultApplications and xdg.mime.addedAssociations
  };

}
