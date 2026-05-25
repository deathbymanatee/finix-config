{
  stdenv,
  lib,
  fetchFromGitHub,
  ...
}:

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "initviz";
  version = "1.0.0-rc1";

  src = fetchFromGitHub {
    owner = "finit-project";
    repo = "InitViz";
    tag = finalAttrs.version;
    hash = "sha256-/kg1p70rONnsyJL0VnAAatnsoBzsqTHyoXyH0JK83Dg=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r initviz $out/bin
  '';
})
