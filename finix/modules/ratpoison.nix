{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.ratpoison;
  xSessionFile = pkgs.writeTextDir "share/xsessions/ratpoison.desktop" ''
    [Desktop Entry]
    Name=Ratpoison
    Comment=Ratpoison tiling window manager
    Exec=${pkgs.lxqt.lxqt-session}/bin/startlxqt    
    Type=Application
    DesktopNames=Ratpoison
  '';

in
{
  options.modules.ratpoison = {
    enable = mkEnableOption "ratpoison";
  };
  config = mkIf cfg.enable {
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
      (lib.hiPrio xSessionFile)
      ratpoison
    ];
  };
}
