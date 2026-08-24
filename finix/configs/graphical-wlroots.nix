/*
  everything you need to run wlroots compositors. this config sets up:

    - seatd as the seat manager (user must be in "seat" group)
    - ly as a greeter
    - enables polkit
    - enables dbus
    - installs graphics drivers
    - installs useful wayland applications
    - sets up fonts
    - enables desktop portals

  it does not set up an audio stack. not like you can run pipewire as a finit system
  service anyway...

  note: this does not INSTALL or ENABLE any wlroots compositors, just the session related plumbing.

  composes with configs.base
*/
{
  lib,
  config,
  modules,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.configs.graphical-wlroots;

in
{
  imports = with modules; [
    udisks2
    polkit
    rtkit
    ly
  ];

  options.configs.graphical-wlroots = {
    enable = mkEnableOption "graphical-wlroots";
    withNoctalia = mkEnableOption "with noctalia";
  };

  config = mkIf cfg.enable {
    configs.base.enable = true;

    # graphical runlevel
    finit.runlevel = 3;

    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    # went with seatd instead of elogind / sessiond
    services.seatd.enable = true;
    services.dbus.enable = true;
    services.ly.enable = true;
    services.polkit.enable = true;
    services.polkit.debug = true;
    services.rtkit.extraGroups = [ config.services.seatd.group ];

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

    environment.systemPackages =
      with pkgs;
      [
        foot
        way-displays
        slurp
        grim
        xsettingsd
        lswt
        satty
        swayidle
        clipse
        rofi
        xclip
        xprop
        wl-clipboard
        playerctl
        swaylock-effects
        gammastep
        libnotify
        wlopm
      ]
      ++ lib.optionals cfg.withNoctalia [ pkgs.noctalia ];

    fonts.fontconfig.enable = true;
    fonts.fontconfig.hinting.style = "full";
    fonts.enableDefaultPackages = true;
    fonts.fontconfig.useEmbeddedBitmaps = true;
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      font-awesome
      source-han-sans
      source-han-serif
      nerd-fonts.jetbrains-mono
      google-fonts
      twitter-color-emoji
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
    ];

    # required for swaylock
    security.pam.services.swaylock = {
      text = "auth include login";
    };

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
