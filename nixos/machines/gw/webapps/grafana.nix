{ config, pkgs, webapps, ... }:
let
  dashboardDomain = "dashboard.${webapps.baseDomain}";

  grafanaInternalAddress = "http://100.115.192.117:${toString config.services.grafana.port}";
in
{
  services.nginx.virtualHosts."${dashboardDomain}" = webapps.vhostWithAuth {
    locations."/" = webapps.locationWithAuth {
      proxyPass = "${grafanaInternalAddress}$request_uri";
    };
  };
}
