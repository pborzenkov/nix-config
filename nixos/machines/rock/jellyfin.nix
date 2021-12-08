{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin = {
    after = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  webapps.apps.jellyfin = {
    subDomain = "jellyfin.lab";
    proxyTo = "http://127.0.0.1:8096";
    locations."/" = { };
    dashboard = {
      name = "Jellyfin";
      category = "app";
      icon = "film";
    };
  };
}
