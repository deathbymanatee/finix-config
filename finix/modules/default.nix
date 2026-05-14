{ config, ... }:
{
  imports = [
    ./cups.nix
    ./sway.nix
    ./packages.nix
    ./plasma.nix
    ./lxqt.nix
    ./ratpoison.nix
    ./pipewire.nix
    ./steam.nix
    ./vesktop.nix
  ];
}
