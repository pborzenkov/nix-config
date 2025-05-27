{
  inputs,
  self,
}: let
  lib = inputs.nixpkgs.lib;
in rec {
  forAllSystems = lib.genAttrs ["x86_64-linux" "aarch64-linux"];

  allNixFiles = dir:
    builtins.map
    (
      n: "${dir}/${n}"
    )
    (
      builtins.attrNames
      (
        lib.filterAttrs
        (n: v: (lib.hasSuffix ".nix" n) && (v == "regular"))
        (builtins.readDir dir)
      )
    );

  allDirs = dir:
    builtins.map
    (
      n: "${dir}/${n}"
    )
    (
      builtins.attrNames
      (
        lib.filterAttrs
        (n: v: (v == "directory") && (builtins.pathExists "${dir}/${n}/default.nix"))
        (builtins.readDir dir)
      )
    );

  makeNixOSConfigurations = systems: (lib.mapAttrs (host: config:
    makeNixOS {
      hostname = host;
      username = config.username or "pbor";
      nixosStateVersion = config.nixosStateVersion;
      homeStateVersion = config.homeStateVersion or null;
      platform = config.platform or "x86_64-linux";
      isDesktop = config.isDesktop or true;
      disabledModules = config.disabledModules or [];
      extraModules = config.extraModules or [];
    })
  systems);

  makeNixOS = {
    hostname,
    username,
    nixosStateVersion,
    homeStateVersion,
    platform,
    isDesktop,
    disabledModules,
    extraModules,
  }:
    lib.nixosSystem {
      system = platform;
      specialArgs = {
        inherit inputs platform hostname username isDesktop;

        nur = import inputs.nur {
          nurpkgs = import inputs.nixpkgs {system = platform;};
        };

        pborlib = {
          inherit allNixFiles allDirs;
        };

        machineSecrets = ../secrets/machines + "/${hostname}";
        sharedSecrets = ../secrets/shared;
      };

      modules = let
        machineDir = ../machines + "/${hostname}";
        machineHardwareConfig = machineDir + "/hardware-configuration.nix";
        machineCustomConfig = machineDir + "/configs";
      in
        [
          inputs.agenix.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix

          ({pkgs, ...}: {
            nixpkgs = {
              config = {
                allowUnfree = true;
              };
              overlays =
                [
                  inputs.nur.overlays.default
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
            };
            disabledModules = disabledModules;

            age = {
              ageBin = "${pkgs.rage}/bin/rage";
              identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
            };
            stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";

            system = {
              stateVersion = nixosStateVersion;
              rebuild.enableNg = true;
            };
          })

          ../modules

          machineDir
          machineHardwareConfig
        ]
        ++ lib.optionals (builtins.pathExists machineCustomConfig) (allNixFiles machineCustomConfig)
        ++ extraModules
        ++ lib.optionals (homeStateVersion != null) [
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${username}" = {
                home = {
                  inherit username;

                  homeDirectory = "/home/${username}";
                  stateVersion = homeStateVersion;
                };
              };
            };
          }
        ];
    };

  makeDeployNodes = systems: (
    lib.mapAttrs (host: config: {
      hostname = config.fqdn or "${host}.lab.borzenkov.net";
      profiles.system.path = inputs.deploy-rs.lib."${config.platform or "x86_64-linux"}".activate.nixos self.nixosConfigurations."${host}";
    })
    (
      lib.filterAttrs (_: config: config.deploy or true) systems
    )
  );
}
