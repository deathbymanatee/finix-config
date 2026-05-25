{ config, ... }:
{
  imports = [
    ./services
    ./cups.nix
    ./sway.nix
    ./packages.nix
    ./plasma.nix
    ./lxqt.nix
    ./ratpoison.nix
    ./pipewire.nix
    ./steam.nix
    ./vesktop.nix
    ./audio-prod.nix
    ./programs
  ];
}
