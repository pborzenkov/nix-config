{ config, pkgs, ... }:

{
  launchd.agents.mpd =
    let
      dataDir = "${config.xdg.dataHome}/mpd";
      mpdConf = pkgs.writeText "mpd.conf" ''
        music_directory "nfs://helios64.lab.borzenkov.net/storage/music"
        playlist_directory "${dataDir}/playlists"
        state_file "${dataDir}/state"
        sticker_file "${dataDir}/sticker.sql"

        bind_to_address "127.0.0.1"
        port "6600"
        zeroconf_enabled "no"

        database {
          plugin "proxy"
          host "rock.lab.borzenkov.net"
        }

        audio_output {
          type "osx"
          name "Default output"
        }
      '';
    in
    {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.mpd}/bin/mpd" "--stdout" "--no-daemon" "${mpdConf}" ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
}
