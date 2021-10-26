{ config, pkgs, webapps, ... }:
let
  photosDomain = "photos.${webapps.baseDomain}";

  port = 8084;
  internalAddress = "http://100.115.192.117:${toString port}";
in
{
  services.nginx.virtualHosts."${photosDomain}" = webapps.vhostWithSSL {
    locations."/" = {
      proxyPass = "${internalAddress}$request_uri";
      proxyWebsockets = true;
    };
  };
}
