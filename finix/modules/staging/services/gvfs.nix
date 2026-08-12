{
  config,
  lib,
  pkgs,
  modules,
  ...
}:
let
  cfg = config.services.gvfs;
  libgudev = pkgs.libgudev.override ({ udev = pkgs.libudev-garden; });
in
{
  imports = [
    # ./fuse.nix
    modules.udisks2
    modules.polkit
  ];

  options = {
    services.gvfs = {
      enable = lib.mkEnableOption "GVfs, a userspace virtual filesystem";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.gvfs;
        defaultText = lib.literalExpression "pkgs.gvfs";
        description = ''
          The package to use for `gvfs`.
        '';
      };
      debug = lib.mkEnableOption "Enable debug output";
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    # programs.fuse.enable = true;

    services.dbus.enable = true;
    services.dbus.packages = [ cfg.package ];

    services.udev.packages = [ pkgs.libmtp.out ];

    services.udisks2.enable = true;

    # Needed for unwrapped applications
    security.pam.environment = {
      GIO_EXTRA_MODULES.default = [ "${cfg.package}/lib/gio/modules" ];
    };

    finit.services.gvfs = {
      description = "userspace virtual filesystem";
      command =
        "${pkgs.dbus}/bin/dbus-launch ${cfg.package}/libexec/gvfsd"
        + lib.optionalString cfg.debug " --debug";
      conditions = "service/dbus/ready";
      log = true;
    };
  };
}
