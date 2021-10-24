{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "nas";
  };

  systemd.services.jellyfin = {
    after = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = [ "/storage" ];
  };
}
