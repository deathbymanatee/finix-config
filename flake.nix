{
  description = "Minimal finix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    finix.url = "github:finix-community/finix";
    community-modules.url = "git+file:///home/ryan/Documents/community-modules";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      finix,
      community-modules,
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
        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
          inherit inputs;
        };

        modules = [
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault pkgs;
          }
          (./finix/hosts/home-desktop/configuration.nix)
          (./finix/modules/shared/base.nix)
          (./finix/modules)
        ];
      };

      nixosConfigurations.virt-manager = finix.lib.finixSystem {
        inherit (pkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
          inherit inputs;
        };

        modules = [
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault pkgs;
          }
          (./finix/hosts/virt-manager/configuration.nix)
          (./finix/modules/shared/base.nix)
          (./finix/modules)
        ];
      };
      nixosConfigurations.thinkpad-e14 = finix.lib.finixSystem {
        inherit (pkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
          inherit inputs;
        };

        modules = [
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault pkgs;
          }
          (./finix/hosts/thinkpad-e14/configuration.nix)
          (./finix/modules/shared/base.nix)
          (./finix/modules)
        ];
      };
      nixosConfigurations.virtualbox = finix.lib.finixSystem {
        inherit (pkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
          inherit inputs;
        };

        modules = with finix.nixosModules; [
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault pkgs;
          }
          (./finix/hosts/virtualbox/configuration.nix)
          (./finix/modules/shared/base.nix)
          (./finix/modules)
        ];
      };
    };
}
