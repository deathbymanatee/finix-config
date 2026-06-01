let
  pkgs = import <nixpkgs> { };
in
{
  wlroots = pkgs.callPackage ./wlroots.nix { };
  labwc = pkgs.callPackage ./labwc.nix { };
}
