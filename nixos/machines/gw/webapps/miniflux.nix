{ config, pkgs, webapps, ... }:
let
  rssDomain = "rss.${webapps.baseDomain}";

  minifluxPort = 8083;
  minifluxInternalAddress = "http://100.115.192.117:${toString minifluxPort}";
in
{
  services.nginx.virtualHosts."${rssDomain}" = webapps.vhostWithAuth {
    locations."/" = webapps.locationWithAuth {
      proxyPass = "${minifluxInternalAddress}$request_uri";
    };

    locations."/fever/" = {
      proxyPass = "${minifluxInternalAddress}$request_uri";
    };
  };
}
