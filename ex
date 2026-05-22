{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.PROGRAM;

in
{
  options.modules.PROGRAM = {
    enable = mkEnableOption "PROGRAM";
  };
  config = mkIf cfg.enable {
    hjem.users.${user} = {
      user = ${user};
      directory = "/home/${user}";
      # other config
    };
  };
}
