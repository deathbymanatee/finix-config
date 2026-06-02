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

  vesktop' = pkgs.vesktop.override (
    lib.optionalAttrs config.services.mdevd.enable {
      pipewire = config.programs.pipewire.package;
    }
  );

in
{
  options.modules.vesktop = {
    enable = mkEnableOption "vesktop";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      vesktop'
    ];
  };
}
