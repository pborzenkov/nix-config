{lib, ...}: {
  services = {
    prowlarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
  };

  systemd.services = lib.genAttrs ["radarr" "readarr"] (name: {
    unitConfig = {
      RequiresMountsFor = ["/storage"];
    };
  });

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
    readarr = {
      subDomain = "readarr";
      proxyTo = "http://127.0.0.1:8787";
      locations."/" = {};
      dashboard = {
        name = "Readarr";
        category = "arr";
        icon = "indent";
      };
    };
  };
}
