{ config, pkgs, ... }:
let
  dashboardDomain = "${config.webapps.apps.grafana.subDomain}.${config.webapps.domain}";
in
{
  webapps.apps.grafana = {
    subDomain = "grafana.lab";
    proxyTo = "http://127.0.0.1:${toString config.services.grafana.port}";
    locations."/" = { auth = true; };
    dashboard = {
      name = "Grafana";
      category = "infra";
      icon = "chart-area";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "grafana" ];
    ensureUsers = [{
      name = "grafana";
      ensurePermissions."DATABASE grafana" = "ALL PRIVILEGES";
    }];
  };

  services.grafana = {
    enable = true;
    analytics.reporting.enable = false;
    auth.anonymous.enable = false;
    addr = "0.0.0.0";

    database = {
      type = "postgres";
      host = "/run/postgresql:5432";
      name = "grafana";
      user = "grafana";
    };

    domain = dashboardDomain;
    rootUrl = "https://${dashboardDomain}";
    security = {
      adminUser = "pavel@borzenkov.net";
      adminPasswordFile = config.sops.secrets.grafana-admin-password.path;
    };

    extraOptions = {
      AUTH_PROXY_ENABLED = "true";
      AUTH_PROXY_HEADER_NAME = config.webapps.userIDHeader;
      AUTH_PROXY_AUTO_SIGN_UP = "true";
      AUTH_DISABLE_LOGIN_FORM = "true";
      AUTH_DISABLE_SIGNOUT_MENU = "true";
      AUTH_AUTH_BASIC_ENABLED = "false";

      ANALYTICS_CHECK_FOR_UPDATES = "false";
      SECURITY_DISABLE_GRAVATAR = "true";

      UNIFIED_ALERTING_ENABLED = "true";
    };

    provision = {
      enable = true;
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

      notifiers = [
        {
          name = "Telegram";
          type = "telegram";
          uid = "telegram";
          is_default = true;
          send_reminder = true;
          frequency = "4h";
          settings = {
            chatid = "321151402";
            bottoken = "\${TELEGRAM_TOKEN}";
            uploadImage = false;
          };
        }
      ];
    };
  };

  systemd.services.grafana = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      SupplementaryGroups = [ config.users.groups.keys.name ];
      EnvironmentFile = [
        config.sops.secrets.tg-bot-alerting-environment.path
      ];
    };
  };

  sops.secrets = {
    grafana-admin-password.owner = config.users.users.grafana.name;
    tg-bot-alerting-environment = { };
  };

  backup.dbBackups.grafana = {
    database = "grafana";
  };
}
