{ config, pkgs, ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "nfs://helios64.lab.borzenkov.net/storage/music";
    network.listenAddress = "any";
    extraConfig = ''
      auto_update "yes"
      audio_output {
        type "null"
        name "Null output"
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 6600 ];
}
