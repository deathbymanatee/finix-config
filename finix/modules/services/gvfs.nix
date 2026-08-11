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

  gvfs = pkgs.gvfs.override {
    libgudev = pkgs.libgudev.override { udev = pkgs.libudev-gardendevd; };
    udisks = config.services.udisks2.package;
  };

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
      # gvfs can be built with multiple configurations
      package = lib.mkPackageOption pkgs [ "gnome" gvfs ] { };
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

    finit.services.gvfs = { };

  };

}
