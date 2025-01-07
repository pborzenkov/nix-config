{
  config,
  lib,
  sharedSops,
  ...
}: let
  cfg = config.pbor.media.audio.mpd;
in {
  options = {
    pbor.media.audio.mpd.enable = (lib.mkEnableOption "Enable mpd") // {default = config.pbor.media.audio.enable;};
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.listenbrainz-mpd-token = {
      sopsFile = sharedSops;
      mode = "0400";
      owner = config.users.users.pbor.name;
      group = config.users.users.pbor.group;
    };

    hm = {
      osConfig,
      config,
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

        mpd-mpris.enable = true;

        listenbrainz-mpd = {
          enable = true;
          settings = {
            submission = {
              token_file = osConfig.sops.secrets.listenbrainz-mpd-token.path;
              enable_cache = true;
            };

            mpd.address = with config.services.mpd.network; "${listenAddress}:${toString port}";
          };
        };
      };

      programs.ncmpcpp = {
        enable = true;
        mpdMusicDir = null;
        bindings = [
          {
            key = "j";
            command = "scroll_down";
          }
          {
            key = "k";
            command = "scroll_up";
          }
          {
            key = "l";
            command = "next_column";
          }
          {
            key = "h";
            command = "previous_column";
          }
        ];
        settings = {
          media_library_primary_tag = "album_artist";
          media_library_hide_album_dates = true;
        };
      };
    };
  };
}
