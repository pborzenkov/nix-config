{
  description = "pborzenkov's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
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

      makeNixOS = {hostname, arch ? "x86_64-linux"}: inputs.nixpkgs.lib.nixosSystem {
        system = arch;
        modules = [
          (./nixos/machines + "/${hostname}")
        ] ++ commonNixOSModules;
        specialArgs = {
          nixos-hardware = inputs.nixos-hardware;
          sops-nix = inputs.sops-nix;
          nur = import inputs.nur {
            nurpkgs = import inputs.nixpkgs { system = arch; };
          };
        };
      };

      makeHome = {hostname, arch ? "x86_64-linux"}: inputs.home-manager.lib.homeManagerConfiguration {
        system = arch;
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
        metal = makeNixOS { hostname = "metal"; };
        rock = makeNixOS { hostname = "rock"; };
        gw = makeNixOS { hostname = "gw"; };
        booking-vm = makeNixOS { hostname = "booking-vm"; arch = "aarch64-linux"; };

        # nix build .#nixosConfigurations.yubikey.config.system.build.isoImage
        yubikey = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./images/yubikey
          ];
        };
      };

      homeConfigurations = {
        metal = makeHome { hostname = "metal"; };
        rock = makeHome { hostname = "rock"; };
        booking-vm = makeHome { hostname = "booking-vm"; arch = "aarch64-linux"; };
      };

      deploy = {
        sshUser = "pbor";

        nodes = {
          metal = {
            hostname = "127.0.0.1";
            fastConnection = true;
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
            hostname = "rock.lan";
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
          nativeBuildInputs = [
            inputs.deploy-rs.packages.${system}.deploy-rs

            pkgs.rnix-lsp
            pkgs.nixpkgs-fmt

            pkgs.sumneko-lua-language-server
            pkgs.luaformatter
            pkgs.efm-langserver
          ];
        };
      });
}
