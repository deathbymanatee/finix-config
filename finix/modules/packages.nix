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
    nix-collect-garbage -d
    sudo nix-collect-garbage -d 
    sudo nix store verify --all
    cd ~/.config/finix-config
    hostname=$HOSTNAME
    nix flake update
    if [[ "$1" == "boot" ]]; then
      sudo nixos-rebuild boot --flake .#$hostname
    else
      sudo nixos-rebuild switch --flake .#$hostname
    fi
    nix store optimise
    sudo nix store optimise
  '';
  rebuild = pkgs.writeShellScriptBin "rebuild" ''
    hostname=$HOSTNAME
    cd ~/.config/finix-config
    git add .
    if [[ "$1" == "boot" ]]; then
      sudo nixos-rebuild boot --flake .#$hostname
    else
      sudo nixos-rebuild switch --flake .#$hostname
    fi
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
