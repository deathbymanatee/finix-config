{
  description = "Minimal finix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    finix.url = "github:deathbymanatee/finix";
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
        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
          inherit inputs;
        };

        modules = with finix.nixosModules; [
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault pkgs;
          }

          (./finix/hosts/home-desktop/configuration.nix)

          (./finix/modules)

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
          sway
          gvfs
          udisks2
          xwayland-satellite
          rtkit
          fwupd
          lxqt
          xserver
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
          (./finix/modules/shared/base.nix)
          (./finix/modules)
          (./finix/hosts/virt-manager/configuration.nix)
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

          (./finix/modules)

          # TODO modules/shared?
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
          sway
          gvfs
          udisks2
          xwayland-satellite
        ];
      };
    };
}
