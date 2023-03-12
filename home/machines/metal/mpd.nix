{
  config,
  pkgs,
  ...
}: {
  services = {
    mpd = {
      enable = true;
      musicDirectory = "https://storage.lab.borzenkov.net/music";
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
