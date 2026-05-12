# base configuration for my lxqt desktop
# wrapper module
{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.lxqt;

  libinput = pkgs.libinput.override (
    lib.optionalAttrs config.services.mdevd.enable {
      udev = pkgs.libudev-zero;
      wacomSupport = false;
    }
  );

in
{
  options.modules.lxqt = {
    enable = mkEnableOption "lxqt";

    # keep an eye on https://github.com/feel-co/hjem/pull/130
    user = mkOption {
      type = types.str;
      default = "";
      description = ''
        User for home directory dotfile symlinking
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.xwayland-satellite.enable = true;
    programs.lxqt.enable = true;
    programs.lxqt.extraPackages =
      with pkgs;
      [
        # core breeze qt theme
        kdePackages.breeze
        kdePackages.breeze-gtk
        kdePackages.qttools
        papirus-icon-theme
        keepassxc
        librewolf
        thunar
        foot
        labwc-tweaks
        way-displays
        gammastep
      ]
      ++ lib.optionals config.services.iwd.enable [
        pkgs.impala
      ];

    fonts.fontconfig.enable = true;
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
      source-han-sans
      source-han-serif
      nerd-fonts.jetbrains-mono
    ];
    fonts.fontconfig.defaultFonts = {
      serif = [
        "Noto Serif"
        "Source Han Serif"
      ];
      sansSerif = [
        "Noto Sans"
        "Source Han Sans"
      ];
      monospace = [
        "Jetbrains Mono Nerd Font"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };

    services.dbus.packages = with pkgs; [
      tumbler
      dconf
      xfconf
    ];

    xdg.mime.enable = true;
    xdg.icons.enable = true;
    xdg.autostart.enable = true;
    xdg.portal.portals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

    system.activation.scripts = mkIf (cfg.user != "") {
      dotfiles = pkgs.lib.stringAfter [ "users" ] ''
        home_dir=/home/${cfg.user}
        assets_dir=$home_dir/.config/finix-config/finix/modules/assets
        if [ ! -d "$home_dir/.config/lxqt/" ]; then
          ln -s -r $assets_dir/lxqt/ $home_dir/.config
          chown ${cfg.user} $home_dir/.config/sway/ -R
        fi
        if [ ! -d "$home_dir/.config/labwc/" ]; then
          ln -s -r $assets_dir/labwc/ $home_dir/.config
          chown ${cfg.user} $home_dir/.config/labwc/ -R
        fi
        if [ ! -d "$home_dir/.config/way-displays" ]; then
          ln -s -r $assets_dir/way-displays/ $home_dir/.config
          chown ${cfg.user} $home_dir/.config/way-displays/ -R
        fi
      '';
    };
  };
}
