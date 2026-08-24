{
  pkgs,
  lib,
  config,
  modules,
  ...
}:

with lib;
let
  cfg = config.modules.qemu;

in
{
  imports = with modules; [ virtualization ];

  options.modules.qemu = {
    enable = mkEnableOption "qemu";
  };
  config = mkIf cfg.enable {
    virtualisation = {
      memorySize = 2048;
      cores = 2;
      qemu = {
        extraArgs = [
          "-display"
          "gtk,gl=off"
          "-device"
          "virtio-vga"
          "-device"
          "virtio-tablet-pci"
          "-monitor"
          "unix:/tmp/vm-monitor.sock,server,nowait"
          "-serial"
          "stdio"
        ];
        package = pkgs.qemu;
        nics.default.args = [
          "user"
          "model=virtio-net-pci"
          "hostfwd=tcp::2222-:22"
        ];
      };
    };
  };
}
