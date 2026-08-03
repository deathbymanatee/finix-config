{
  description = "finix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    finix.url = "github:finix-community/finix";
    community-modules.url = "github:finix-community/community-modules";
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
        config.permittedInsecurePackages = [
        ];
      };

      mkSystem =
        hostname:
        finix.lib.finixSystem {
          inherit (pkgs) lib;
          specialArgs = {
            modulesPath = toString nixpkgs + "/nixos/modules";
            inherit inputs;
          };

          modules = [
            {
              nixpkgs.pkgs = nixpkgs.lib.mkDefault pkgs;
            }
            { networking.hostName = hostname; }
            (./finix/hosts/${hostname}/configuration.nix)
            (./finix/configs)
            (./finix/modules)
          ];
        };

    in
    {
      nixosConfigurations = {
        thinkpad-e14 = mkSystem "thinkpad-e14";
        virtualbox = mkSystem "virtualbox";
        home-desktop = mkSystem "home-desktop";
        virt-manager = mkSystem "virt-manager";
      };
    };
}
