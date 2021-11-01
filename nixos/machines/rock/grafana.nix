{ config, pkgs, ... }:
let
  dashboardDomain = "${config.webapps.apps.grafana.subDomain}.${config.webapps.domain}";

  dbUser = "grafana";
  dbPassword = "grafana";
  dbName = "grafana";

  pgsu = "${pkgs.sudo}/bin/sudo -u ${config.services.postgresql.superUser}";
  pgbin = "${config.services.postgresql.package}/bin";
  preStart = pkgs.writeScript "grafana-pre-start" ''
    #!${pkgs.runtimeShell}
    db_exists() {
      [ "$(${pgsu} ${pgbin}/psql -Atc "select 1 from pg_database where datname='$1'")" == "1" ]
    }
    if ! db_exists "${dbName}"; then
      ${pgsu} ${pgbin}/psql postgres -c "CREATE ROLE ${dbUser} WITH LOGIN NOCREATEDB NOCREATEROLE ENCRYPTED PASSWORD '${dbPassword}'"
      ${pgsu} ${pgbin}/createdb --owner "${dbUser}" "${dbName}"
    fi
  '';
in
{
  webapps.apps.grafana = {
    subDomain = "dashboard";
    proxyTo = "http://127.0.0.1:${toString config.services.grafana.port}";
    locations."/" = { auth = true; };
  };

  services.grafana = {
    enable = true;
    analytics.reporting.enable = false;
    auth.anonymous.enable = false;
    addr = "0.0.0.0";

    database = {
      type = "postgres";
      host = "127.0.0.1:5432";
      name = dbName;
      user = dbUser;
      password = dbPassword;
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
    };
  };

  systemd.services.grafana = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      SupplementaryGroups = [ config.users.groups.keys.name ];
      ExecStartPre = [ "+${preStart}" ];
    };
  };

  sops.secrets.grafana-admin-password = {
    owner = config.users.users.grafana.name;
  };

  backup.dbBackups.grafana = {
    database = "grafana";
  };
}
