{
  description = "finix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=ddd7720cc351111b47fa618dd1e7afebf0c8e661";
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
        config.permittedInsecurePackages = [
          "librewolf-bin-151.0.1-2"
          "librewolf-bin-unwrapped-151.0.1-2"

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
            (./finix/modules/configs/base.nix)
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
