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

  pipewire' =
    (pkgs.pipewire.override (
      lib.optionalAttrs config.services.mdevd.enable {
        enableSystemd = false;
        udev = pkgs.libudev-zero;
      }
    )).overrideAttrs
      (o: {
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2398#note_2967898
        patches =
          o.patches or [ ] ++ lib.optionals config.services.mdevd.enable [ ./assets/pipewire/pipewire.patch ];
      });

  xdg-desktop-portal-wlr' = pkgs.xdg-desktop-portal-wlr.override ({ pipewire = pipewire'; });

in
{
  options.modules.lxqt = {
    enable = mkEnableOption "lxqt";

    # TODO monitor https://github.com/feel-co/hjem/pull/130
    user = mkOption {
      type = types.str;
      default = "";
      description = ''
        User for home directory dotfile symlinking
      '';
    };

    enableXorg = lib.mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable lxqt xorg session
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.xwayland-satellite.enable = true;
    programs.pmount.enable = true;
    programs.lxqt.enable = true;
    programs.lxqt.xsession.enable = cfg.enableXorg;
    programs.lxqt.iconTheme = pkgs.papirus-icon-theme;
    services.xserver.enable = cfg.enableXorg;
    programs.lxqt.extraPackages =
      with pkgs;
      [
        # core breeze qt theme
        kdePackages.breeze
        kdePackages.breeze-icons
        kdePackages.breeze-gtk
        kdePackages.qttools
        kdePackages.ark
        hicolor-icon-theme
        keepassxc
        librewolf
        thunar
        thunar-volman
        thunar-archive-plugin
        foot
        labwc-tweaks
        way-displays
        gammastep
        slurp
        grim
        xsettingsd
        lswt
        satty
        swayidle
        wlprop
        lxqt.qlipper
        swaylock-effects
        playerctl
        lxqt-panel-profiles
      ]
      ++ lib.optionals config.services.iwd.enable [
        pkgs.impala
      ];

    fonts.fontconfig.enable = true;
    fonts.enableDefaultPackages = true;
    fonts.fontconfig.useEmbeddedBitmaps = true;
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
      thunar
      thunar-volman
      thunar-archive-plugin
    ];

    security.pam.services.swaylock = {
      text = "auth include login";
    };

    xdg.mime.enable = true;
    xdg.icons.enable = true;
    xdg.autostart.enable = true;
    xdg.portal.portals = [
      xdg-desktop-portal-wlr'
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
