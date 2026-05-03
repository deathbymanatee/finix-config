{
  description = "Minimal finix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    finix.url = "github:finix-community/finix?ref=568a8da1536f97cadef6d5e81fa41a63930d4d70";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      finix,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.home-desktop = finix.lib.finixSystem {
        inherit (pkgs) lib;

        modules = with finix.nixosModules; [
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault pkgs;
          }

          (./finix/hosts/home-desktop/configuration.nix)

          nix-daemon
          openssh
          sysklogd
          limine
          sudo
          polkit
          getty
          bash
          dhcpcd
          lemurs
          flatpak
        ];

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
        };
      };
    };
}
