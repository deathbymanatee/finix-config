{ config, ... }:
{
  imports = [
    ./cups.nix
    ./sway.nix
    ./packages.nix
    ./plasma.nix
    ./lxqt.nix
    ./programs
  ];
}
