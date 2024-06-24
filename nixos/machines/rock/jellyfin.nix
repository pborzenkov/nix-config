{...}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin = {
    unitConfig.RequiresMountsFor = ["/storage"];
  };

  webapps.apps.jellyfin = {
    subDomain = "jellyfin";
    proxyTo = "http://127.0.0.1:8096";
    locations."/" = {};
    custom = {
      forceSSL = false;
    };
    dashboard = {
      name = "Jellyfin";
      category = "app";
      icon = "film";
    };
  };
}
