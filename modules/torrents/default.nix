{
  config,
  lib,
  pkgs,
  isDesktop,
  username,
  ...
}: let
  cfg = config.pbor.torrents;
in {
  options = {
    pbor.torrents.enable = (lib.mkEnableOption "Enable torrents") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      home = {
        packages = with pkgs; [
          rustmission
        ];
      };

      xdg.configFile."rustmission/config.toml" = {
        source = (pkgs.formats.toml {}).generate "wofi-power-menu.toml" {
          connection = {
            url = "https://torrents.lab.borzenkov.net/transmission/rpc";
          };
        };
      };
    };
  };
}
