{
  ...
}:
{
  pbor.webapps.apps = {
    victorialogs = {
      subDomain = "logs";
      auth.rbac = [ "group:monitoring" ];
      proxyTo = "http://127.0.0.1:9428";
      locations."/" = { };
      locations."/select" = {
        skip_auth = true;
      };
      dashboard = {
        name = "VictoriaLogs";
        category = "infra";
        icon = "align-justify";
      };
    };
  };

  services.victorialogs = {
    enable = true;
    extraOptions = [ "-retentionPeriod=2w" ];
  };

  networking.firewall.allowedTCPPorts = [ 9428 ];
}
