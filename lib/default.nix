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
        overlays = [
          inputs.nur.overlay
          (import ../overlay.nix)
          (final: _prev: {
            unstable = import inputs.nixpkgs-unstable {
              system = final.system;
              config = {
                allowUnfree = true;
              };
            };
          })
        ];
      };
      extraSpecialArgs = {
        inherit inputs platform username hostname stateVersion isDesktop;
      };

      modules = [
        # TODO: remove after stylix
        inputs.base16.homeManagerModule
        {
          scheme = "${inputs.tt-schemes}/base16/onedark.yaml";
        }

        ../home
      ];
    };
}
