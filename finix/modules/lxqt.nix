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

  xdg-desktop-portal-wlr' = pkgs.xdg-desktop-portal-wlr.override ({
    pipewire = config.programs.pipewire.package;
  });

  libinput = pkgs.libinput.override ({
    udev = pkgs.libudev-zero;
    wacomSupport = false;
  });

  labwc' = pkgs.callPackage ./packages/labwc.nix {
    enableSystemd = false;
    inherit libinput;
    wlroots_0_20 = pkgs.wlroots_0_20.override ({ inherit libinput; });
  };

in
{
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
        labwc-gtktheme

        rofi
      ]
      ++ lib.optionals config.services.iwd.enable [
        pkgs.impala
      ];
    programs.lxqt.wayland.compositor = lib.mkForce labwc';

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
