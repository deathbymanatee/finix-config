# GVfs

{
  config,
  lib,
  pkgs,
  modules,
  ...
}:
let
  cfg = config.services.gvfs;

  # gardendevd needs libudev-garden; mdevd/keventd need libudev-zero
  udevApi =
    if config.services.gardendevd.enable then
      pkgs.libudev-garden
    else if config.services.mdevd.enable || config.services.keventd.enable then
      pkgs.libudev-zero
    else
      null;
in
{
  imports = [
    ./fuse.nix
    modules.polkit
    modules.udisks2
  ];

  options = {
    services.gvfs = {
      enable = lib.mkEnableOption "GVfs, a userspace virtual filesystem";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.gvfs.override ({
          udisks = config.services.udisks2.package;
        });
        defaultText = lib.literalExpression "pkgs.labwc";
        description = ''
          The package to use for `labwc`.
        '';
      };
      debug = lib.mkEnableOption "Enable debug output";
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    programs.fuse.enable = true;

    services.dbus.enable = lib.mkForce true;
    services.dbus.packages = [ cfg.package ];

    services.udev.packages = [ pkgs.libmtp.out ];

    services.udisks2.enable = true;

    # Needed for unwrapped applications
    security.pam.environment = {
      GIO_EXTRA_MODULES.default = [ "${cfg.package}/lib/gio/modules" ];
    };

    finit.services.gvfs = {
      description = "userspace virtual filesystem";
      command = "${cfg.package}/libexec/gvfsd" + lib.optionalString cfg.debug " --debug";
      conditions = "service/dbus/ready";
      log = true;
    };
  };

}
