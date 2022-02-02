{
  description = "pborzenkov's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.inxpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    base16 = {
      url = "github:lukebfox/base16-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, ... } @ inputs:
    let
      nur-no-pkgs = import inputs.nur {
        nurpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
      };
      commonNixpkgsConfig = {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [
            inputs.nur.overlay
          ];
        };
      };
      commonNixOSModules = [
        ./nixos/nix.nix
        ./nixos/users.nix
        ./nixos/sudo.nix
        ./nixos/tailscale.nix
        ({
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
        } // commonNixpkgsConfig)
      ];

      makeNixOS = hostname: inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (./nixos/machines + "/${hostname}")
        ] ++ commonNixOSModules;
        specialArgs = {
          nixos-hardware = inputs.nixos-hardware;
          sops-nix = inputs.sops-nix;
          nur = nur-no-pkgs;
        };
      };

      makeHome = hostname: inputs.home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        stateVersion = "21.05";
        homeDirectory = "/home/pbor";
        username = "pbor";
        configuration = {
          imports = [
            (inputs.base16.homeManagerModules.base16)

            (./home/machines + "/${hostname}")
          ];

          programs.home-manager.enable = true;
          themes.base16 = {
            enable = true;
            scheme = "onedark";
            variant = "onedark";
          };
        } // commonNixpkgsConfig;
      };
    in
    {
      nixosConfigurations = {
        metal = makeNixOS "metal";
        rock = makeNixOS "rock";
        gw = makeNixOS "gw";

        # nix build .#nixosConfigurations.yubikey.config.system.build.isoImage
        yubikey = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./images/yubikey
          ];
        };
      };

      homeConfigurations = {
        metal = makeHome "metal";
        rock = makeHome "rock";
      };

      deploy = {
        sshUser = "pbor";

        nodes = {
          metal = {
            hostname = "127.0.0.1";
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
            hostname = "192.168.88.3";
            profiles = {
              system = {
                user = "root";
                path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.rock;
                confirmTimeout = 600;
              };
              home = {
                user = "pbor";
                path = inputs.deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations.rock;
              };
            };
          };

          gw = {
            hostname = "borzenkov.net";
            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.gw;
            };
          };
        };
      };
    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [ inputs.deploy-rs.packages.${system}.deploy-rs ];
        };
      });
}
