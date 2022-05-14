{ config, pkgs, ... }:

{
  services = {
    mpd = {
      enable = true;
      musicDirectory = "nfs://helios64.lab.borzenkov.net/storage/music";
      dbFile = null;
      extraConfig = ''
        database {
          plugin "proxy"
          host "rock.lab.borzenkov.net"
        }

        audio_output {
          type "pipewire"
          name "Default output"
        }
      '';
    };
    mpdris2 = {
      enable = true;
      mpd.musicDirectory = "/storage/music";
    };
  };
}
