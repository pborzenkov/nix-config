{ config, pkgs, nur, ... }:
{
  imports = [
    nur.repos.pborzenkov.modules.gonic
  ];

  services.gonic = {
    enable = true;
    musicPath = "/storage/music";
    podcastPath = "/storage/podcasts";

    scanInterval = 10;
  };

  systemd.services.gonic = {
    after = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  backup.fsBackups = {
    music = {
      paths = [
        "/storage/music"
      ];
    };
  };
}
