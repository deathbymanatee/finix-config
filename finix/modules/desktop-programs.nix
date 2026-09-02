{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.desktop-programs;

in
{
  options.modules.desktop-programs = {
    enable = mkEnableOption "desktop-programs";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      librewolf-bin
      libreoffice
      joplin-desktop
      kdePackages.okular
      vlc
      qbittorrent
    ];
  };
}
