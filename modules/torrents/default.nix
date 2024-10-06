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
          unstable.stig
        ];
      };

      xdg.configFile."stig/rc".text = ''
        set connect.host torrents.lab.borzenkov.net
        set connect.port 443
        set connect.tls on
      '';
    };
  };
}
