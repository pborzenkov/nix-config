{
  description = "pborzenkov's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
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
        utils.follows = "flake-utils";
      };
    };
    valheim-server = {
      url = "github:aidalgol/valheim-server-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Base16 generator
    base16 = {
      url = "github:SenchoPens/base16.nix";
    };

    # Base16 themes
    tt-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };

    # Base16 templates
    base16-wofi = {
      url = "sourcehut:~knezi/base16-wofi";
      flake = false;
    };
    base16-textmate = {
      url = "github:chriskempson/base16-textmate";
      flake = false;
    };
    base16-tridactyl = {
      url = "github:tridactyl/base16-tridactyl";
      flake = false;
    };
    base16-zathura = {
      url = "github:haozeke/base16-zathura";
      flake = false;
    };
  };

  outputs = {self, ...} @ inputs: let
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
      ({
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
        }
        // commonNixpkgsConfig)
    ];

    makeNixOS = {
      hostname,
      arch ? "x86_64-linux",
      disabledModules ? [],
      customModules ? [],
    }:
      inputs.nixpkgs.lib.nixosSystem {
        system = arch;
        modules =
          [
            (./nixos/machines + "/${hostname}")
            {
              disabledModules = disabledModules;
            }
          ]
          ++ commonNixOSModules
          ++ customModules;
        specialArgs = {
          inherit inputs;

          nur = import inputs.nur {
            nurpkgs = import inputs.nixpkgs {system = arch;};
          };
          # pkgs-unstable = import inputs.nixpkgs-unstable {system = arch;};
        };
      };

    makeHome = {
      hostname,
      arch ? "x86_64-linux",
      home ? "/home",
      user ? "pbor",
      extra ? {},
    }:
      inputs.home-manager.lib.homeManagerConfiguration {
        modules = [
          inputs.base16.homeManagerModule
          (./home/machines + "/${hostname}")

          {
            home = {
              username = user;
              homeDirectory = "${home}/${user}";
              stateVersion = "21.05";
            };

            programs.home-manager.enable = true;
            scheme = "${inputs.tt-schemes}/base16/onedark.yaml";
          }
          extra
        ];

        extraSpecialArgs = {
          inherit inputs;

          # pkgs-unstable = import inputs.nixpkgs-unstable {system = arch;};
        };
        pkgs = import inputs.nixpkgs {
          system = arch;
          config = {
            allowUnfree = true;
          };
          overlays = [
            inputs.nur.overlay
            (import ./overlay.nix)
          ];
        };
      };
  in
    {
      nixosConfigurations = {
        metal = makeNixOS {hostname = "metal";};
        rock =
          makeNixOS
          {
            hostname = "rock";
            disabledModules = ["services/networking/openvpn.nix"];
            customModules = [
              inputs.valheim-server.nixosModules.default
            ];
          };
        gw =
          makeNixOS
          {hostname = "gw";};

        # nix build .#nixosConfigurations.yubikey.config.system.build.isoImage
        yubikey =
          inputs.nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            modules = [
              ./images/yubikey
            ];
          };
      };

      homeConfigurations = {
        metal = makeHome {hostname = "metal";};
        rock = makeHome {hostname = "rock";};
        trance = makeHome {
          hostname = "trance";
          extra = {
            nix.registry.nixpkgs.flake = inputs.nixpkgs;
          };
        };
      };

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
    }
    // inputs.flake-utils.lib.eachDefaultSystem
    (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      devShell = pkgs.mkShell {
        nativeBuildInputs = [
          inputs.deploy-rs.packages.${system}.deploy-rs

          pkgs.luaformatter
        ];
      };
    });
}
