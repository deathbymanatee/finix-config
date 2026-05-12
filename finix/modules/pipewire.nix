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
      pkgs.easyeffects
      pkgs.calf
      pkgs.qpwgraph
    ];
    environment.etc."security/limits.conf".text = ''
      @audio   -   rtprio     95
      @audio   -   nice       -19
      @audio   -   memlock    4194304
    '';
    services.mdevd.hotplugRules = mkIf config.services.mdevd.enable (
      lib.mkMerge [
        (lib.mkAfter ''
          SUBSYSTEM=input;.* root:input 660
          SUBSYSTEM=sound;.* root:audio 660
        '')

        ''
          grsec       root:root 660
          kmem        root:root 640
          mem         root:root 640
          port        root:root 640
          console     root:tty 600 @chmod 600 $MDEV
          card[0-9]   root:video 660 =dri/

          # alsa sound devices and audio stuff
          pcm.*       root:audio 0660 =snd/
          control.*   root:audio 0660 =snd/
          midi.*      root:audio 0660 =snd/
          seq         root:audio 0660 =snd/
          timer       root:audio 0660 =snd/

          adsp        root:audio 0660 >sound/
          audio       root:audio 0660 >sound/
          dsp         root:audio 0660 >sound/
          mixer       root:audio 0660 >sound/
          sequencer.* root:audio 0660 >sound/

          event[0-9]+ root:input 660 =input/
          mice        root:input 660 =input/
          mouse[0-9]+ root:input 660 =input/

          rfkill      root:${config.services.seatd.group} 660
        ''
      ]
    );
  };
}
