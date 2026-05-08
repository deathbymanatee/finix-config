{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.pipewire;
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

  wireplumber' = pkgs.wireplumber.override (
    lib.optionalAttrs config.services.mdevd.enable {
      pipewire = pipewire';
    }
  );

in
{
  options.modules.pipewire = {
    enable = mkEnableOption "pipewire";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pipewire'
      wireplumber'
    ];
  };
}
