{ config, ... }:
{
  imports = [
    ./services/docker.nix
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
  ];
}
