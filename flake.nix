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
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    # Base16 generator
    base16 = {
      url = "github:SenchoPens/base16.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Base16 themes
    base16-onedark-scheme = {
      url = "github:LalitMaganti/base16-onedark-scheme";
      flake = false;
    };

    # Base16 templates
    base16-alacritty = {
      url = "github:aarowill/base16-alacritty";
      flake = false;
    };
    base16-helix = {
      url = "github:krgn/base16-helix";
      flake = false;
    };
    base16-rofi = {
      url = "github:jordiorlando/base16-rofi";
      flake = false;
    };
    base16-textmate = {
      url = "github:chriskempson/base16-textmate";
      flake = false;
    };
    base16-tmux = {
      url = "github:mattdavis90/base16-tmux";
      flake = false;
    };
    base16-vim = {
      url = "github:chriskempson/base16-vim";
      flake = false;
    };
    base16-zathura = {
      url = "github:haozeke/base16-zathura";
      flake = false;
    };
  };

  outputs = { self, ... } @ inputs:
    let
      commonNixpkgsConfig = {
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [
            inputs.nur.overlay
            (import ./overlay.nix)
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
      commonDarwinModules = [
        ./darwin/nix.nix
        ./darwin/base.nix
        ./darwin/tailscale.nix
        ({
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
        } // commonNixpkgsConfig)
      ];

      makeNixOS = { hostname, arch ? "x86_64-linux" }: inputs.nixpkgs.lib.nixosSystem {
        system = arch;
        modules = [
          (./nixos/machines + "/${hostname}")
        ] ++ commonNixOSModules;
        specialArgs = {
          inherit inputs;

          nur = import inputs.nur {
            nurpkgs = import inputs.nixpkgs { system = arch; };
          };
        };
      };

      makeDarwin = { hostname, arch ? "aarch64-darwin" }: inputs.darwin.lib.darwinSystem {
        system = arch;
        modules = [
          (./darwin/machines + "/${hostname}")
        ] ++ commonDarwinModules;
        specialArgs = {
          nur = import inputs.nur {
            nurpkgs = import inputs.nixpkgs { system = arch; };
          };
        };
      };

      makeHome = { hostname, arch ? "x86_64-linux", home ? "/home", user ? "pbor" }: inputs.home-manager.lib.homeManagerConfiguration {
        system = arch;
        stateVersion = "21.05";
        homeDirectory = "${home}/${user}";
        username = user;
        configuration = {
          imports = [
            inputs.base16.homeManagerModule

            (./home/machines + "/${hostname}")
          ];

          programs.home-manager.enable = true;
          scheme = "${inputs.base16-onedark-scheme}/onedark.yaml";
        } // commonNixpkgsConfig;
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    in
    {
      nixosConfigurations = {
        metal = makeNixOS { hostname = "metal"; };
        rock = makeNixOS { hostname = "rock"; };
        gw = makeNixOS { hostname = "gw"; };

        # nix build .#nixosConfigurations.yubikey.config.system.build.isoImage
        yubikey = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./images/yubikey
          ];
        };
      };

      darwinConfigurations = {
        booking-laptop = makeDarwin { hostname = "booking-laptop"; };
      };

      homeConfigurations = {
        metal = makeHome { hostname = "metal"; };
        rock = makeHome { hostname = "rock"; };
        booking-laptop = makeHome { hostname = "booking-laptop"; arch = "aarch64-darwin"; home = "/Users"; user = "pborzenkov"; };
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

            pkgs.nixpkgs-fmt
            pkgs.luaformatter
          ];
        };
      });
}
