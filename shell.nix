# shell for enabling temporary packages since nix-shell doesn't have NIX_PATH set for some reason
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    labwc-gtktheme
    libva-utils
  ];
}
