{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.packages;
  maintenance = pkgs.writeShellScriptBin "maintenance" ''
    sudo nix-collect-garbage -d 
    sudo nix store verify --all
    sudo nix store repair --all
    cd ~/.config/finix-config
    hostname=$HOSTNAME
    nix flake update
    sudo nixos-rebuild switch --flake .#$hostname --upgrade
  '';
  rebuild = pkgs.writeShellScriptBin "rebuild" ''
    hostname=$HOSTNAME
    cd ~/.config/finix-config
    git add .
    sudo nixos-rebuild switch --flake .#$hostname
  '';

in
{
  options.modules.packages = {
    enable = mkEnableOption "packages";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      maintenance
      rebuild
    ];
  };
}
