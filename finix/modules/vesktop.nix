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
  pipewire' =
    (pkgs.pipewire.override (
      lib.optionalAttrs config.services.mdevd.enable {
        enableSystemd = false;
        udev = pkgs.libudev-zero;
      }
    )).overrideAttrs
      (o: {
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2398#note_2967898
        patches =
          o.patches or [ ] ++ lib.optionals config.services.mdevd.enable [ ./assets/pipewire/pipewire.patch ];
      });

  vesktop' = pkgs.vesktop.override (
    lib.optionalAttrs config.services.mdevd.enable {
      pipewire = pipewire';
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
