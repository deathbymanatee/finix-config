{
  description = "Minimal finix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    finix.url = "github:deathbymanatee/finix";

    # noctalia = {
    #   url = "github:noctalia-dev/noctalia-shell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
        ];
      };

      nixosConfigurations.virt-manager = finix.lib.finixSystem {
        inherit (pkgs) lib;

        specialArgs = {
          modulesPath = toString nixpkgs + "/nixos/modules";
          inherit inputs;
        };

        modules = with finix.nixosModules; [
          {
            nixpkgs.pkgs = nixpkgs.lib.mkDefault pkgs;
          }

          (./finix/hosts/virt-manager/configuration.nix)

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
