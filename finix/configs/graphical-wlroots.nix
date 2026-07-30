/*
  everything you need to run wlroots compositors. this config sets up:

    - seatd as the seat manager (user must be in "seat" group)
    - ly as a greeter
    - enables polkit
    - enables dbus
    - installs graphics drivers

  it does not set up an audio stack. not like you can run pipewire as a finit system
  service anyway...

  note: this does not INSTALL or ENABLE any wlroots compositors, just the session related plumbing.

  composes with configs.base
*/
{
  lib,
  config,
  modules,
  ...
}:

with lib;
let
  cfg = config.configs.graphical-wlroots;

in
{
  imports = with modules; [
    udisks2
    polkit
    rtkit
    ly
  ];

  options.configs.graphical-wlroots = {
    enable = mkEnableOption "graphical-wlroots";
  };

  config = mkIf cfg.enable {
    configs.base.enable = true;

    # graphical runlevel
    finit.runlevel = 3;

    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    # requires dev manager that can read udev rules
    services.udisks2.enable =
      config.services.gardendevd.enable || config.services.udev.enable || config.services.keventd.enable;
    services.seatd.enable = true;
    services.dbus.enable = true;
    services.ly.enable = true;
    services.polkit.enable = true;
    services.rtkit.extraGroups = [ config.services.seatd.group ];

    # invocation still requires sudo; just removes password prompt
    providers.privileges.rules = lib.optionals config.services.seatd.enable [
      {
        command = "/run/current-system/sw/bin/poweroff";
        groups = [ config.services.seatd.group ];
        requirePassword = false;
      }
      {
        command = "/run/current-system/sw/bin/reboot";
        groups = [ config.services.seatd.group ];
        requirePassword = false;
      }
    ];
  };
}
