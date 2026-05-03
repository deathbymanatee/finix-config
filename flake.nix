{
  description = "Minimal finix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    finix.url = "github:finix-community/finix?ref=b7a33ff6b856c85fb13c7e9dc03fd41c824299ba";
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
