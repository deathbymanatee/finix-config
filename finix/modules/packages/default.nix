let
  pkgs = import <nixpkgs> { };
in
{
  labwc = pkgs.callPackage ./labwc.nix { enableSystemd = false; };
}
