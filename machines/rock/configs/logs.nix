{
  ...
}:
{
  pbor.webapps.apps = {
    victorialogs = {
      subDomain = "logs";
      auth.rbac = [ "group:monitoring" ];
      proxyTo = "http://127.0.0.1:9428";
      custom = {
        http2 = false;
      };
      locations."/" = { };
      locations."/select" = {
        skip_auth = true;
      };
      locations."/insert" = {
        skip_auth = true;
        custom = {
          extraConfig = ''
            client_max_body_size 1G;
          '';
        };
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
}
