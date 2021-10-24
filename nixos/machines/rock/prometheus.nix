{ config, pkgs, ... }:

let
  botPort = toString 9095;
in
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
              "rock.lab.borzenkov.net:9090"
            ];
          }
        ];
      }
    ];

    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      configuration = {
        receivers = [
          {
            name = "alertmanager-bot";
            webhook_configs = [
              {
                send_resolved = true;
                url = "http://127.0.0.1:${botPort}";
              }
            ];
          }
        ];
        route = {
          receiver = "alertmanager-bot";
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "4h";
        };
      };
    };
    alertmanagers = [
      {
        scheme = "http";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.alertmanager.port}"
            ];
          }
        ];
      }
    ];
  };

  systemd.services.tg-bot-alerting = {
    description = "Telegram bot for alertmanager";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
            ${pkgs.alertmanager-bot}/bin/alertmanager-bot \
        --alertmanager.url=http://127.0.0.1:${toString config.services.prometheus.alertmanager.port} \
        --listen.addr=127.0.0.1:${botPort} \
        --bolt.path=%S/tg-bot-alerting/bot.db \
        --store=bolt \
        --telegram.admin=321151402
      '';
      EnvironmentFile = [
        config.sops.secrets.tg-bot-alerting-environment.path
      ];
      Restart = "always";
      DynamicUser = true;
      StateDirectory = "tg-bot-alerting";
    };
  };

  sops.secrets.tg-bot-alerting-environment = { };
}
