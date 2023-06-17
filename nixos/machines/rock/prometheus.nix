{
  config,
  pkgs,
  ...
}: {
  webapps.apps.prometheus = {
    subDomain = "prometheus";
    proxyTo = "http://127.0.0.1:${toString config.services.prometheus.port}";
    locations."/" = {auth = true;};
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
      {
        job_name = "p1";
        static_configs = [
          {
            targets = [
              "rock.lab.borzenkov.net:4545"
            ];
          }
        ];
      }
    ];
  };

  systemd.services = {
    prometheus-node-exporter.serviceConfig.StateDirectory = "prometheus-node-exporter";
    p1-exporter = {
      description = "Prometheus exporter for DMSR meter";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        DynamicUser = true;
        ExecStart = ''
          ${pkgs.p1-exporter}/bin/p1-exporter \
            --address 0.0.0.0:4545 \
            --p1-address 192.168.88.20:23
        '';
        Restart = "always";
      };
    };
  };
}
