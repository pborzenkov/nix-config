{ config, pkgs, ... }:

{
  webapps.apps.prometheus = {
    subDomain = "prometheus";
    proxyTo = "http://127.0.0.1:${toString config.services.prometheus.port}";
    locations."/" = { auth = true; };
    dashboard = {
      name = "Prometheus";
      category = "infra";
      icon = "chart-line";
    };
  };

  services.prometheus = {
    enable = true;
    checkConfig = true;

    globalConfig = {
      scrape_interval = "15s";
      scrape_timeout = "10s";
    };

    retentionTime = "7d";

    exporters = {
      node = {
        enable = true;
        extraFlags = [
          "--collector.textfile.directory /var/lib/prometheus-node-exporter"
        ];
      };
    };

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [
              "rock.lab.borzenkov.net:9090"
            ];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "helios64.lab.borzenkov.net:9100"
              "rock.lab.borzenkov.net:9100"
            ];
          }
        ];
      }
    ];
  };

  systemd.services."prometheus-node-exporter".serviceConfig.StateDirectory = "prometheus-node-exporter";
}
