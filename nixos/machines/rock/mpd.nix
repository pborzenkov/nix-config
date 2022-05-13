{ config, pkgs, ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "nfs://helios64.lab.borzenkov.net/storage";
    network.listenAddress = "any";
    extraConfig = ''
      auto_update "yes"
    '';
  };
}
