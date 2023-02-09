{
  config,
  pkgs,
  ...
}: {
  services.mpd = {
    enable = true;
    musicDirectory = "nfs://helios64.lab.borzenkov.net/storage/music";
    network.listenAddress = "any";
    extraConfig = ''
      auto_update "yes"
      audio_output {
        type "pipewire"
        name "Living Room"
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [6600];

  webapps.apps.mpdsonic = {
    subDomain = "music";
    proxyTo = "http://127.0.0.1:6601";
    locations."/" = {};
  };

  systemd.services.mpdsonic = {
    description = "mpdsonic - expose MPD library via Subsonic protocol";
    after = ["network.target" "mpd.service"];
    wantedBy = ["multi-user.target"];

    path = [pkgs.ffmpeg];

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "mpdsonic";
      ExecStart = ''
        ${pkgs.mpdsonic}/bin/mpdsonic \
          -a 127.0.0.1:6601 \
          -u pavel@borzenkov.net \
          --mpd-address 127.0.0.1:6600 \
          --mpd-library nfs://helios64.lab.borzenkov.net/storage/music
      '';
      Restart = "always";
      RestartSec = 5;
      EnvironmentFile = [
        config.sops.secrets.mpdsonic-environment.path
      ];
    };
  };

  users.users.mpd.extraGroups = ["pipewire"];

  sops.secrets.mpdsonic-environment = {};

  backup.fsBackups = {
    music = {
      paths = [
        "/storage/music"
        "/var/lib/mpd"
      ];
    };
  };
}
