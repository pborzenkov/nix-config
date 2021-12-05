{ config, pkgs, ... }:

{
  webapps.apps.prometheus = {
    subDomain = "prometheus.lab";
    proxyTo = "http://127.0.0.1:${toString config.services.prometheus.port}";
    locations."/" = { auth = true; };
  };

  services.prometheus = {
    enable = true;
    checkConfig = true;

    globalConfig = {
      scrape_interval = "15s";
      scrape_timeout = "10s";
    };

    retentionTime = "7d";

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [
              "rock.lan:9090"
            ];
          }
        ];
      }
    ];
  };
}
