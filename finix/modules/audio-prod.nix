{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.audioProd;

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

  pipewire32' =
    (pkgs.pkgsi686Linux.pipewire.override (
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

  jack-libs = pkgs.runCommand "jack-libs" { } ''
    mkdir -p "$out/lib"
    ln -s "${pipewire'.jack}/lib" "$out/lib/pipewire"
  '';

in
{
  options.modules.audioProd = {
    enable = mkEnableOption "Audio production stack";

    configPackages = mkOption {
      type = listOf package;
      default = [ ];
      example = literalExpression ''
        [
                  (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-loopback.conf" '''
                    context.modules = [
                    {   name = libpipewire-module-loopback
                        args = {
                          node.description = "Scarlett Focusrite Line 1"
                          capture.props = {
                              audio.position = [ FL ]
                              stream.dont-remix = true
                              node.target = "alsa_input.usb-Focusrite_Scarlett_Solo_USB_Y7ZD17C24495BC-00.analog-stereo"
                              node.passive = true
                          }
                          playback.props = {
                              node.name = "SF_mono_in_1"
                              media.class = "Audio/Source"
                              audio.position = [ MONO ]
                          }
                        }
                    }
                    ]
                  ''')
                ]'';
      description = ''
        List of packages that provide PipeWire configuration, in the form of
        `share/pipewire/*/*.conf` files.

        LV2 dependencies will be picked up from config packages automatically
        via `passthru.requiredLv2Packages`.
      '';
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      reaper
      # https://github.com/reaper-oss/sws/wiki/Installing-the-SWS-Extension-(for-end-users)/
      reaper-sws-extension

      # wine64 also???
      winePackages.yabridge
      yabridgectl

      pipewire'
      wireplumber'

      pkgs.easyeffects
      pkgs.calf
      pkgs.qjackctl

      jack-libs
    ];

    security.pam.environment = {
      LD_LIBRARY_PATH.default = "${pipewire'.jack}/lib";
    };

    environment.etc."security/limits.conf".text = ''
      @audio   -   rtprio     95
      @audio   -   nice       -19
      @audio   -   memlock    4194304
    '';

    environment.etc = {
      "alsa/conf.d/49-pipewire-modules.conf" = {
        text = ''
          pcm_type.pipewire {
            libs.native = ${pipewire'}/lib/alsa-lib/libasound_module_pcm_pipewire.so ;
            libs.32Bit = ${pipewire32'}/lib/alsa-lib/libasound_module_pcm_pipewire.so ;
          }
          ctl_type.pipewire {
            libs.native = ${pipewire'}/lib/alsa-lib/libasound_module_ctl_pipewire.so ;
            libs.32Bit = ${pipewire32'}/lib/alsa-lib/libasound_module_ctl_pipewire.so ;
          }
        '';
      };

      "alsa/conf.d/50-pipewire.conf" = {
        source = "${pipewire'}/share/alsa/alsa.conf.d/50-pipewire.conf";
      };

      "alsa/conf.d/99-pipewire-default.conf" = {
        source = "${pipewire'}/share/alsa/alsa.conf.d/99-pipewire-default.conf";
      };
    };

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
