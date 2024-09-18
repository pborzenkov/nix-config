{
  config,
  pkgs,
  ...
}: {
  services.mpd = {
    enable = true;
    musicDirectory = "/storage/music";
    network.listenAddress = "any";
    extraConfig = ''
      auto_update "yes"
      audio_output {
        type "pipewire"
        name "Living Room"
      }
    '';
  };
  systemd.services.mpd.unitConfig = {
    RequiresMountsFor = ["/storage"];
  };

  networking.firewall.allowedTCPPorts = [6600];

  systemd.services = {
    listenbrainz-mpd = let
      cfg = (pkgs.formats.toml {}).generate "listenbrainz-mpd.toml" {
        submission = {
          token_file = "/run/credentials/listenbrainz-mpd.service/token";
          enable_cache = false;
        };
        mpd = {
          address = "127.0.0.1:6600";
        };
      };
    in {
      description = "ListenBrainz submission client for MPD";
      after = ["network.target" "mpd.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        LoadCredential = "token:${config.sops.secrets.listenbrainz-mpd-token.path}";
        ExecStart = "${pkgs.listenbrainz-mpd}/bin/listenbrainz-mpd -c ${cfg}";
        Restart = "always";
      };
    };
  };

  users.users.mpd.extraGroups = ["pipewire"];

  sops.secrets = {
    listenbrainz-mpd-token = {};
  };

  backup.fsBackups = {
    music = {
      paths = [
        "/storage/music"
        "/var/lib/mpd"
      ];
    };
  };
}
