{ config, pkgs, ... }:

{
  services.plex = {
    enable = true;
    openFirewall = true;
    group = "nas";
  };

  systemd.services.plex = {
    after = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [ "/storage" ];
  };
}
