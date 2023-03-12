{
  config,
  pkgs,
  ...
}: {
  services = {
    prowlarr.enable = true;
    radarr.enable = true;
  };

  systemd.services = {
    radarr = {
      unitConfig = {
        RequiresMountsFor = ["/storage"];
      };
    };
  };

  webapps.apps = {
    prowlarr = {
      subDomain = "prowlarr";
      proxyTo = "http://127.0.0.1:9696";
      locations."/" = {};
      dashboard = {
        name = "Prowlarr";
        category = "arr";
        icon = "indent";
      };
    };
    radarr = {
      subDomain = "radarr";
      proxyTo = "http://127.0.0.1:7878";
      locations."/" = {};
      dashboard = {
        name = "Radarr";
        category = "arr";
        icon = "indent";
      };
    };
  };
}
