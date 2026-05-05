{ config, ... }:
{
  imports = [
    ./cups.nix
    ./sway.nix
    ./packages.nix
    ./plasma.nix
    ./thunar.nix
  ];
}
