{ config, pkgs, nur, ... }:
{
  imports = [
    nur.repos.pborzenkov.modules.gonic
  ];

  webapps.apps.gonic = {
    subDomain = "music";
    proxyTo = "http://127.0.0.1:4747";
    locations."/" = { };
    dashboard = {
      name = "Gonic";
      category = "app";
      icon = "music";
    };
  };

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
