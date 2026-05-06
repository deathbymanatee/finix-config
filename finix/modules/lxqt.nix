# base configuration for my lxqt desktop
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.lxqt;

in
{
  options.modules.lxqt = {
    enable = mkEnableOption "lxqt";
  };

  config = lib.mkIf cfg.enable {
    # security.pam = {
    #   environment = {
    #     QT_QPA_PLATFORMTHEME.default = [ "gtk3" ];
    #   };
    # };

    programs = {
      lxqt.enable = true;
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
      # gui
      keepassxc
      librewolf
      thunar
    ];

    services.dbus.packages = with pkgs; [
      tumbler
      dconf
      xfconf
    ];

    xdg = {
      mime.enable = true;
      icons.enable = true;
      autostart.enable = true;
    };

  };
}
