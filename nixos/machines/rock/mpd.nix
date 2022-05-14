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
        name "Void"
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 6600 ];

  webapps.apps.mpd = {
    subDomain = "music";
    locations."/" = {
      custom = {
        root = "/storage/music";
      };
    };
    custom = {
      forceSSL = false; # https://github.com/MusicPlayerDaemon/MPD/issues/1477
    };
  };

  backup.fsBackups = {
    music = {
      paths = [
        "/storage/music"
      ];
    };
  };
}
