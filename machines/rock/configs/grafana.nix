{
  config,
  machineSecrets,
  ...
}: let
  dashboardDomain = "${config.pbor.webapps.apps.grafana.subDomain}.${config.pbor.webapps.domain}";
in {
  pbor.webapps.apps.grafana = {
    subDomain = "grafana";
    auth.rbac = ["group:monitoring"];
    proxyTo = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
    locations."/" = {};
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
        ensureDBOwnership = true;
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
        header_name = "Remote-User";
        headers = "Name:Remote-Name Email:Remote-Email Groups:Remote-Groups";
        auto_sign_up = true;
      };

      database = {
        type = "postgres";
        host = "/run/postgresql:5432";
        name = "grafana";
        user = "grafana";
      };

      security = {
        admin_user = "pavel";
        admin_password__file = config.age.secrets.grafana-admin-password.path;
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
        config.age.secrets.tg-bot-alerting-environment.path
      ];
    };
  };

  age.secrets = {
    grafana-admin-password = {
      file = machineSecrets + "/grafana-admin-password.age";
      owner = config.users.users.grafana.name;
    };
    tg-bot-alerting-environment.file = machineSecrets + "/tg-bot-alerting-environment.age";
  };

  pbor.backup.dbBackups.grafana = {
    database = "grafana";
  };
}
