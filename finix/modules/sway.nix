# base configuration for my sway desktop
{
  pkgs,
  config,
  lib,
  modules,
  ...
}:
with lib;
let
  cfg = config.modules.sway;

in
{
  imports = with modules; [
    sway
  ];

  options.modules.sway = {
    enable = mkEnableOption "sway";
    user = mkOption {
      type = types.str;
      default = "";
      description = ''
        User for home directory dotfile symlinking
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      polkit = {
        # sudoless power commands allegedly
        extraConfig = ''
          polkit.addRule(function (action, subject) {
            if (
              subject.isInGroup("seat") &&
              [
                "/run/current-system/sw/bin/reboot",
                "/run/current-system/sw/bin/poweroff",
              ].indexOf(action.id) !== -1
            ) {
              return polkit.Result.YES;
            }
          });
        '';
      };
    };

    users.groups.power = { };

    security.pam = {
      environment = {
        QT_QPA_PLATFORMTHEME.default = [ "gtk3" ];
      };
    };

    programs = {
      sway.enable = true;
      # from ./thunar.nix
    };

    fonts = {
      fontconfig.enable = true;
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        font-awesome
        source-han-sans
        source-han-serif
        nerd-fonts.jetbrains-mono
      ];
      # fontconfig.defaultFonts = {
      #   serif = [
      #     "Noto Serif"
      #     "Source Han Serif"
      #   ];
      #   sansSerif = [
      #     "Noto Sans"
      #     "Source Han Sans"
      #   ];
      #   monospace = [
      #     "Jetbrains Mono Nerd Font"
      #   ];
      #   emoji = [
      #     "Noto Color Emoji"
      #   ];
      # };
    };

    environment.systemPackages = with pkgs; [
      libinput
      wmenu
      wl-clipboard-rs
      swayidle
      swaylock
      grim
      slurp
      wf-recorder
      dunst
      swaybg
      keepassxc
      vlc
      kdePackages.ark
      kdePackages.breeze
      kdePackages.breeze-gtk
      kdePackages.breeze-icons
      gammastep
      geeqie
      brightnessctl
      playerctl
      glib
      gsettings-desktop-schemas
      gtk3
      gtk4
      libsForQt5.qtstyleplugins
      nwg-look
      autotiling
      joplin-desktop
      waybar
      networkmanagerapplet
      blueman
      papirus-icon-theme
      tumbler
      foot
      dconf
      xfconf
      thunar
      thunar-volman
      thunar-archive-plugin
      xdg-utils

      # gui
      keepassxc
      librewolf-bin

      # displays
      way-displays
    ];

    services.dbus.packages = with pkgs; [
      tumbler
      dconf
      xfconf
    ];

    xdg = {
      portal.portals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
      mime.enable = true;
      icons.enable = true;
      autostart.enable = true;
    };

    system.activation.scripts = mkIf (cfg.user != "") {
      dotfiles = pkgs.lib.stringAfter [ "users" ] ''
        home_dir=/home/${cfg.user}
        assets_dir=$home_dir/.config/finix-config/finix/modules/assets
        if [ ! -d "$home_dir/.config/sway/" ]; then
          ln -s -r $assets_dir/sway/ $home_dir/.config
          chown ${cfg.user} $home_dir/.config/sway/ -R
        fi
        if [ ! -d "$home_dir/.config/waybar/" ]; then
          ln -s -r $assets_dir/waybar/ $home_dir/.config
          chown ${cfg.user} $home_dir/.config/waybar/ -R
        fi
        if [ ! -d "$home_dir/Pictures/Wallpapers/" ]; then
          mkdir -p $home_dir/Pictures/Wallpapers
          chown ${cfg.user} $home_dir/Pictures/Wallpapers/ -R
        fi
        if [ ! -e "$home_dir/Pictures/Wallpapers/Forest_For_The_Trees.jpg" ]; then
          ln -s -r $assets_dir/wallpapers/Forest_For_The_Trees.jpg $home_dir/Pictures/Wallpapers/
          chown ${cfg.user} $home_dir/Pictures/Wallpapers/Forest_For_The_Trees.jpg -R
        fi
        if [ ! -d "$home_dir/.config/way-displays" ]; then
          ln -s -r $assets_dir/way-displays/ $home_dir/.config
          chown ${cfg.user} $home_dir/.config/way-displays/ -R
        fi
      '';
    };
  };
}
