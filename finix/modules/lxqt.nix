# wrapper module
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
    polkit
    rtkit
    udisks2
    ly
    xorg
    brightnessctl
    pmount
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

    # graphical runlevel
    finit.runlevel = 3;

    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    programs.pmount.enable = true;
    programs.lxqt.enable = true;
    programs.lxqt.xsession.enable = cfg.enableXorg;
    programs.lxqt.iconTheme = pkgs.papirus-icon-theme;
    programs.xorg.enable = cfg.enableXorg;
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
        librewolf-bin
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
        wl-clipboard
        cliphist
        xclip
        xprop
        clipse

        rofi
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

    # requires dev manager that can read udev rules
    services.udisks2.enable =
      config.services.gardendevd.enable || config.services.udev.enable || config.services.keventd.enable;
    services.seatd.enable = true;
    services.dbus.enable = true;
    services.ly.enable = true;
    services.polkit.enable = true;
    services.rtkit.enable = true;
    services.rtkit.extraGroups = [ config.services.seatd.group ];
    services.dbus.packages = with pkgs; [
      tumbler
      dconf
      xfconf
    ];

    security.pam.services.swaylock = {
      text = "auth include login";
    };

    # invocation still requires sudo; just removes password prompt
    providers.privileges.rules = lib.optionals config.services.seatd.enable [
      {
        command = "/run/current-system/sw/bin/poweroff";
        groups = [ config.services.seatd.group ];
        requirePassword = false;
      }
      {
        command = "/run/current-system/sw/bin/reboot";
        groups = [ config.services.seatd.group ];
        requirePassword = false;
      }
    ];

    xdg.portal.enable = true;
    xdg.mime.enable = true;
    xdg.icons.enable = true;
    xdg.autostart.enable = true;
    xdg.portal.portals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
