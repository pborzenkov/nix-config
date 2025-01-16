{
  description = "pborzenkov's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    valheim-server = {
      url = "github:aidalgol/valheim-server-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = {self, ...} @ inputs: let
    lib = import ./lib {inherit inputs self;};

    systems = {
      metal = {
        nixosStateVersion = "23.05";
        homeStateVersion = "21.05";
        deploy = false;
      };
      rock = {
        nixosStateVersion = "23.05";
        homeStateVersion = "21.05";
        isDesktop = false;
        extraModules = [
          inputs.valheim-server.nixosModules.default
        ];
      };
      gw = {
        nixosStateVersion = "23.05";
        homeStateVersion = "24.05";
        isDesktop = false;
      };
      yubikey = {
        nixosStateVersion = "24.05";
        isDesktop = false;
        deploy = false;
      };
    };
  in {
    nixosConfigurations = lib.makeNixOSConfigurations systems;
    deploy = {
      sshUser = "pbor";
      user = "root";
      nodes = lib.makeDeployNodes systems;
    };

    devShells = lib.forAllSystems (
      system: let
        pkgs = import inputs.nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          nativeBuildInputs = [
            inputs.deploy-rs.packages.${system}.deploy-rs
            pkgs.sops
          ];
        };
      }
    );
  };
}
