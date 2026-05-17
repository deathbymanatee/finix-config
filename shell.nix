# shell for enabling temporary packages since nix-shell doesn't have NIX_PATH set for some reason
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
  # libinput = pkgs.libinput.override ({
  #   udev = pkgs.libudev-zero;
  #   wacomSupport = false;
  # });
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    # labwc theme creator
    # labwc-gtktheme

    # vulkan utils (provides vulkaninfo)
    # libva-utils

    # kwin test
    # (kdePackages.kwin.override ({ inherit libinput; }))

    perl
    unzip
    zip
  ];
}
