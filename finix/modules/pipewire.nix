{
  lib,
  config,
  pkgs,
  modules,
  ...
}:

with lib;
let
  cfg = config.modules.pipewire;

in
{
  imports = with modules; [
    pipewire
    wireplumber
  ];

  options.modules.pipewire = {
    enable = mkEnableOption "pipewire";
  };
  config = mkIf cfg.enable {
    programs.pipewire.enable = true;
    programs.wireplumber.enable = true;

    environment.systemPackages = with pkgs; [
      easyeffects
      calf
      qpwgraph
    ];
  };
}
