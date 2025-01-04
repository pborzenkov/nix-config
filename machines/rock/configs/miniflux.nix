{config, ...}: let
  port = "8083";
in {
  pbor.webapps.apps.miniflux = {
    subDomain = "rss";
    auth.rbac = ["group:rss"];
    proxyTo = "http://127.0.0.1:${port}";
    locations."/" = {};
    dashboard = {
      name = "Miniflux";
      category = "app";
      icon = "rss";
    };
  };

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "0.0.0.0:${port}";
      BASE_URL = "https://${config.pbor.webapps.apps.miniflux.subDomain}.${config.pbor.webapps.domain}";

      AUTH_PROXY_HEADER = "Remote-User";
      AUTH_PROXY_USER_CREATION = "true";
    };
    adminCredentialsFile = config.sops.secrets.miniflux-admin-credentials.path;
  };

  pbor.backup.dbBackups.miniflux = {
    database = "miniflux";
  };

  sops.secrets.miniflux-admin-credentials = {};
}
