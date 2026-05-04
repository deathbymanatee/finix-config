# base configuration for my sway desktop
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.sway;

in
{
  imports = [ ./soteria.nix ];
  options.modules.sway = {
    enable = mkEnableOption "sway";
    user = mkOption {
      type = types.str;
      default = "";
      description = ''
        User for home directory dotfile syncing.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      gvfs.enable = true;
      seatd.enable = true;
      lemurs = {
        enable = true;
        settings = {
          wayland.wayland_sessions_path = lib.mkForce "/run/current-system/sw/share/wayland-sessions";
        };
      };
      polkit = {
        enable = true;
        extraConfig = ''
          polkit.addRule(function (action, subject) {
            if (
              subject.isInGroup("power") &&
              [
                "org.freedesktop.login1.reboot",
                "org.freedesktop.login1.reboot-multiple-sessions",
                "org.freedesktop.login1.power-off",
                "org.freedesktop.login1.power-off-multiple-sessions",
              ].indexOf(action.id) !== -1
            ) {
              return polkit.Result.YES;
            }
          });
        '';
      };
      soteria.enable = true;
    };

    programs = {
      sway.enable = true;
    };

    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        font-awesome
        source-han-sans
        source-han-serif
      ];
      fontconfig.defaultFonts = {
        serif = [
          "Noto Serif"
          "Source Han Serif"
        ];
        sansSerif = [
          "Noto Sans"
          "Source Han Sans"
        ];
      };
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

      # gui
      keepassxc
      librewolf
      thunar
      thunar-volman
      thunar-archive-plugin

      # theming
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

      # displays
      way-displays
    ];

    services.dbus.packages = with pkgs; [ tumbler ];

    # hacky and bad but only here because of no hjem / home-manager :(
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
      '';
    };
  };
}
