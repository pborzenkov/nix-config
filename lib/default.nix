{inputs}: let
  lib = inputs.nixpkgs.lib;

  nixpkgsConfig = {
    allowUnfree = true;
  };
  overlays =
    [
      inputs.nur.overlay
      (import ../overlay.nix)
    ]
    ++ lib.optional (inputs ? "nixpkgs-unstable")
    (final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.system;
        config = {
          allowUnfree = true;
        };
      };
    });
in rec {
  forAllSystems = lib.genAttrs ["x86_64-linux" "aarch64-linux"];

  makeNixOSConfigurations = systems:
    lib.mapAttrs (host: config:
      makeNixOS {
        hostname = host;
        stateVersion = config.nixosStateVersion;
        platform = config.platform or "x86_64-linux";
        isDesktop = config.isDesktop or true;
      })
    (lib.filterAttrs (_: config: config ? nixosStateVersion)
      systems);

  makeNixOS = {
    hostname,
    stateVersion,
    platform,
    isDesktop,
  }:
    lib.nixosSystem {
      system = platform;
      specialArgs = {
        inherit inputs platform hostname stateVersion isDesktop;

        nur = import inputs.nur {
          nurpkgs = import inputs.nixpkgs {system = platform;};
        };
      };

      modules = [
        ../nixos
        {
          nixpkgs = {
            config = nixpkgsConfig;
            overlays = overlays;
          };
        }
      ];
    };

  makeHomeConfigurations = systems:
    lib.mapAttrs (host: config:
      makeHome {
        hostname = host;
        stateVersion = config.homeStateVersion;
        platform = config.platform or "x86_64-linux";
        username = config.username or "pbor";
        isDesktop = config.isDesktop or true;
      })
    (lib.filterAttrs (_: config: config ? homeStateVersion)
      systems);

  makeHome = {
    hostname,
    username,
    stateVersion,
    platform,
    isDesktop,
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = platform;
        config = nixpkgsConfig;
        overlays = overlays;
      };
      extraSpecialArgs = {
        inherit inputs platform username hostname stateVersion isDesktop;
      };

      modules = [
        ../home
      ];
    };
}
