{ config, lib, pkgs, ... }:

let
  cfg = config.macapps;
in
{
  options.macapps = {
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = ''
        List of packages to link to ~/Applications
      '';
      example = [ pkgs.alacritty ];
    };
  };

  config = lib.mkIf ((builtins.length cfg.packages) > 0) {
    system = {
      build.applications = lib.mkForce (
        pkgs.buildEnv {
          name = "applications";
          paths = cfg.packages;
          pathsToLink = "/Applications";
        }
      );

      activationScripts.applications.text = lib.mkForce (
        ''
          if [[ -L "$HOME/Applications" ]]; then
            rm "$HOME/Applications"
            mkdir -p "$HOME/Applications/Nix";
          fi

          rm -rf "$HOME/Applications/Nix"
          mkdir -p "$HOME/Applications/Nix"

          for app in $(find ${config.system.build.applications}/Applications -maxdepth 1 -type l); do
            src="$(/usr/bin/stat -f%Y "$app")"
            echo "Copying $app"
            cp -rL "$src" "$HOME/Applications/Nix"
          done
        ''
      );
    };
  };
}
