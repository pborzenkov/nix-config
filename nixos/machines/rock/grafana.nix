{
  config,
  pkgs,
  ...
}: let
  dashboardDomain = "${config.webapps.apps.grafana.subDomain}.${config.webapps.domain}";
in {
  webapps.apps.grafana = {
    subDomain = "grafana";
    proxyTo = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
    locations."/" = {auth = true;};
    dashboard = {
      name = "Grafana";
      category = "infra";
      icon = "chart-area";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["grafana"];
    ensureUsers = [
      {
        name = "grafana";
        ensurePermissions."DATABASE grafana" = "ALL PRIVILEGES";
      }
    ];
  };

  services.grafana = {
    enable = true;

    settings = {
      analytics = {
        check_for_updates = false;
        reporting_enabled = false;
      };

      auth = {
        disable_login_form = true;
        disable_signout_menu = true;
      };

      "auth.anonymous" = {
        enabled = false;
      };

      "auth.basic" = {
        enabled = false;
      };

      "auth.proxy" = {
        enabled = true;
        header_name = config.webapps.userIDHeader;
        auto_sign_up = true;
      };

      database = {
        type = "postgres";
        host = "/run/postgresql:5432";
        name = "grafana";
        user = "grafana";
      };

      security = {
        admin_user = "pavel@borzenkov.net";
        admin_password__file = config.sops.secrets.grafana-admin-password.path;
        disable_gravatar = true;
      };

      server = {
        domain = dashboardDomain;
        http_addr = "0.0.0.0";
        root_url = "https://${dashboardDomain}";
      };

      unified_alerting = {
        enabled = true;
      };
    };

    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            access = "proxy";
            isDefault = true;
            jsonData = {
              timeInterval = config.services.prometheus.globalConfig.scrape_interval;
            };
          }
        ];
      };

      alerting.contactPoints.settings = {
        contactPoints = [
          {
            name = "Telegram";
            receivers = [
              {
                type = "telegram";
                uid = "telegram";
                settings = {
                  chatid = "321151402";
                  bottoken = "\${TELEGRAM_TOKEN}";
                  uploadImage = false;
                };
              }
            ];
          }
        ];
      };
    };
  };

  systemd.services.grafana = {
    after = ["postgresql.service"];
    requires = ["postgresql.service"];
    serviceConfig = {
      SupplementaryGroups = [config.users.groups.keys.name];
      EnvironmentFile = [
        config.sops.secrets.tg-bot-alerting-environment.path
      ];
    };
  };

  sops.secrets = {
    grafana-admin-password.owner = config.users.users.grafana.name;
    tg-bot-alerting-environment = {};
  };

  backup.dbBackups.grafana = {
    database = "grafana";
  };
}
