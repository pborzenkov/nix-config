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
  };

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "0.0.0.0:${port}";
      BASE_URL = "https://${config.webapps.apps.miniflux.subDomain}.${config.webapps.domain}";

      AUTH_PROXY_HEADER = "${config.webapps.userIDHeader}";
      AUTH_PROXY_USER_CREATION = "true";
    };
  };

  backup.dbBackups.miniflux = {
    database = "miniflux";
  };
}
