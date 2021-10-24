{ config, pkgs, webapps, ... }:

{
  webapps.apps.miniflux = {
    subDomain = "rss";
  };

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "0.0.0.0:${toString 8083}";
      BASE_URL = "https://${config.webapps.apps.miniflux.subDomain}.${config.webapps.domain}";

      AUTH_PROXY_HEADER = "${config.webapps.userIDHeader}";
      AUTH_PROXY_USER_CREATION = "true";
    };
  };

  backup.dbBackups.miniflux = {
    database = "miniflux";
  };
}
