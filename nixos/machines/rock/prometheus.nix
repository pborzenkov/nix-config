{ config, pkgs, ... }:

{
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
