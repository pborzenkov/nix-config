{
  description = "pborzenkov's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.inxpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = github:Mic92/sops-nix;
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
    in
    {
      nixosConfigurations = {
        rock = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos/machines/rock
          ] ++ commonNixOSModules;
          specialArgs = {
            nixos-hardware = inputs.nixos-hardware;
            sops-nix = inputs.sops-nix;
            nur = nur-no-pkgs;
          };
        };

        gw = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos/machines/gw
          ] ++ commonNixOSModules;
          specialArgs = {
            nixos-hardware = inputs.nixos-hardware;
            sops-nix = inputs.sops-nix;
          };
        };

        # nix build .#nixosConfigurations.yubikey.config.system.build.isoImage
        yubikey = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./images/yubikey
          ];
        };
      };

      homeConfigurations = {
        rock = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          stateVersion = "21.05";
          homeDirectory = "/home/pbor";
          username = "pbor";
          configuration = {
            imports = [
              (inputs.base16.homeManagerModules.base16)

              ./home/machines/rock
            ];

            programs.home-manager.enable = true;
            themes.base16 = {
              enable = true;
              scheme = "onedark";
              variant = "onedark";
            };
          } // commonNixpkgsConfig;
        };
      };
    };
}
