# base configuration for my lxqt desktop
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
  };

  config = lib.mkIf cfg.enable {
    # security.pam = {
    #   environment = {
    #     QT_QPA_PLATFORMTHEME.default = [ "gtk3" ];
    #   };
    # };

    services.xserver.enable = true;

    programs = {
      lxqt.enable = true;
      # needs more testing outside of a vm
      # lxqt.compositor.package = pkgs.kdePackages.kwin.override {
      #   inherit libinput;
      # };
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
