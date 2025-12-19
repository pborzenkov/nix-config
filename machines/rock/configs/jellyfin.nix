{ ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin = {
    serviceConfig.SupplementaryGroups = [ "storage" ];
    unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  pbor.webapps.apps.jellyfin = {
    subDomain = "jellyfin";
    proxyTo = "http://127.0.0.1:8096";
    locations = {
      "/".custom = {
        extraConfig = ''
          proxy_buffering off;
        '';
      };
      "/socket".custom = {
        proxyWebsockets = true;
      };
    };
    custom = {
      forceSSL = false;
      extraConfig = ''
        client_max_body_size 20M;
      '';
    };
    dashboard = {
      name = "Jellyfin";
      category = "app";
      icon = "film";
    };
  };
}
