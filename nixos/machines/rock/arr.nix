{
  config,
  lib,
  pkgs,
  ...
}: {
  services = {
    bazarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
  };

  systemd.services =
    (lib.genAttrs ["bazarr" "radarr" "sonarr"] (name: {
      unitConfig = {
        RequiresMountsFor = ["/storage"];
      };
    }))
    // {
      autobrr = {
        description = "Modern, easy to use download automation for torrents and usenet.";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          DynamicUser = true;
          Type = "simple";
          Restart = "on-failure";
          StateDirectory = "autobrr";
          ExecStart = "${pkgs.nur.repos.pborzenkov.autobrr}/bin/autobrr --config /var/lib/autobrr";
          EnvironmentFile = [
            config.sops.secrets.autobrr-environment.path
          ];
        };
        environment = {
          AUTOBRR_HOST = "127.0.0.1";
          AUTOBRR_PORT = "7474";
          AUTOBRR_DATABASE_TYPE = "sqlite";
          AUTOBRR_CHECK_FOR_UPDATES = "false";
        };
      };
    };

  sops.secrets.autobrr-environment = {};

  webapps.apps = {
    autobrr = {
      subDomain = "autobrr";
      proxyTo = "http://127.0.0.1:7474";
      locations."/" = {};
      dashboard = {
        name = "Autobrr";
        category = "arr";
        icon = "download";
      };
    };
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

  backup.fsBackups.arr = {
    paths = [
      "/var/lib/autobrr"
      "/var/lib/bazarr"
      "/var/lib/prowlarr"
      "/var/lib/radarr"
      "/var/lib/sonarr"
    ];
  };
}
