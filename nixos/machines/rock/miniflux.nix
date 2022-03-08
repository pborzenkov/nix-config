{ config, pkgs, webapps, ... }:

let
  port = "8083";
in
{
  webapps.apps.miniflux = {
    subDomain = "rss.lab";
    proxyTo = "http://127.0.0.1:${port}";
    locations."/" = { auth = true; };
    locations."/fever/" = { };
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
      BASE_URL = "https://${config.webapps.apps.miniflux.subDomain}.${config.webapps.domain}";

      AUTH_PROXY_HEADER = "${config.webapps.userIDHeader}";
      AUTH_PROXY_USER_CREATION = "true";
    };
    adminCredentialsFile = config.sops.secrets.miniflux-admin-credentials.path;
  };

  backup.dbBackups.miniflux = {
    database = "miniflux";
  };

  sops.secrets.miniflux-admin-credentials = { };
}
