# vesktop rebuild with patched pipewire for (hopefully) better screenshare performance
{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.vesktop;

in
{
  options.modules.vesktop = {
    enable = mkEnableOption "vesktop";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.vesktop
    ];
  };
}
