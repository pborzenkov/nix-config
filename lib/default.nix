{inputs}: {
  makeHome = {
    username ? "pbor",
    hostname,
    stateVersion,
    platform ? "x86_64-linux",
    isDesktop ? true,
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = platform;
        config = {
          allowUnfree = true;
        };
        overlays =
          [
            inputs.nur.overlay
            (import ../overlay.nix)
          ]
          ++ inputs.nixpkgs.lib.optional (inputs ? "nixpkgs-unstable")
          (final: _prev: {
            unstable = import inputs.nixpkgs-unstable {
              system = final.system;
              config = {
                allowUnfree = true;
              };
            };
          });
      };
      extraSpecialArgs = {
        inherit inputs platform username hostname stateVersion isDesktop;
      };

      modules = [
        ../home
      ];
    };
}
