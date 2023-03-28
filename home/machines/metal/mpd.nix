{pkgs, ...}: {
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

  systemd.user.services.listenbrainz-mpd = let
    cfg = (pkgs.formats.toml {}).generate "listenbrainz-mpd.toml" {
      submission = {
        token_file = "/run/secrets/listenbrainz-mpd-token";
        enable_cache = false;
      };
      mpd = {
        address = "127.0.0.1:6600";
      };
    };
  in {
    Unit = {
      Description = "ListenBrainz submission client for MPD";
      After = ["network.target" "mpd.service"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.listenbrainz-mpd}/bin/listenbrainz-mpd -c ${cfg}";
      Restart = "always";
    };
    Install.WantedBy = ["default.target"];
  };
}
