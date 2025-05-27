{lib, ...}: {
  # # TODO:
  # nixpkgs.config.permittedInsecurePackages = [
  #   "aspnetcore-runtime-wrapped-6.0.36"
  #   "aspnetcore-runtime-6.0.36"
  #   "dotnet-sdk-wrapped-6.0.428"
  #   "dotnet-sdk-6.0.428"
  # ];

  services = {
    bazarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
  };

  systemd.services = lib.genAttrs ["bazarr" "radarr" "sonarr"] (name: {
    unitConfig = {
      RequiresMountsFor = ["/storage"];
    };
  });

  pbor.webapps.apps = {
    bazarr = {
      subDomain = "bazarr";
      proxyTo = "http://127.0.0.1:6767";
      locations."/" = {};
      dashboard = {
        name = "Bazaar";
        category = "arr";
        icon = "indent";
      };
    };
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
    sonarr = {
      subDomain = "sonarr";
      proxyTo = "http://127.0.0.1:8989";
      locations."/" = {};
      dashboard = {
        name = "Sonaar";
        category = "arr";
        icon = "indent";
      };
    };
  };

  pbor.backup.fsBackups.arr = {
    paths = [
      "/var/lib/bazarr"
      "/var/lib/prowlarr"
      "/var/lib/radarr"
      "/var/lib/sonarr"
    ];
  };
}
