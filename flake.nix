{
  description = "pborzenkov's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    nur.url = "github:nix-community/NUR";
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
      url = "github:pborzenkov/stylix/missing-modules";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = {self, ...} @ inputs: let
    lib = import ./lib {inherit inputs;};

    systems = {
      metal = {
        nixosStateVersion = "23.05";
        homeStateVersion = "21.05";
      };
      rock = {
        nixosStateVersion = "23.05";
        homeStateVersion = "21.05";
        isDesktop = false;
      };
      gw = {
        nixosStateVersion = "23.05";
        isDesktop = false;
      };
      yubikey = {
        nixosStateVersion = "24.05";
        isDesktop = false;
      };
    };
  in {
    nixosConfigurations = lib.makeNixOSConfigurations systems;
    homeConfigurations = lib.makeHomeConfigurations systems;

    deploy = {
      sshUser = "pbor";

      nodes = {
        metal = {
          hostname = "metal.lab.borzenkov.net";
          profiles = {
            system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.metal;
            };
            home = {
              user = "pbor";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations.metal;
            };
          };
        };

        rock = {
          hostname = "rock.lab.borzenkov.net";
          profiles = {
            system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.rock;
            };
            home = {
              user = "pbor";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations.rock;
            };
          };
        };

        gw = {
          hostname = "gw.lab.borzenkov.net";
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.gw;
          };
        };
      };
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
