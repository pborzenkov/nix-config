{
  config,
  pkgs,
  sharedSecrets,
  ...
}:
{
  services.mpd = {
    enable = true;
    musicDirectory = "/storage/music";
    network.listenAddress = "any";
    extraConfig = ''
      auto_update "yes"
    '';
  };
  systemd.services.mpd = {
    serviceConfig.SupplementaryGroups = [ "storage" ];
    unitConfig.RequiresMountsFor = [ "/storage" ];
  };

  networking.firewall.allowedTCPPorts = [ 6600 ];

  systemd.services = {
    listenbrainz-mpd =
      let
        cfg = (pkgs.formats.toml { }).generate "listenbrainz-mpd.toml" {
          submission = {
            token_file = "/run/credentials/listenbrainz-mpd.service/token";
            enable_cache = false;
          };
          mpd = {
            address = "127.0.0.1:6600";
          };
        };
      in
      {
        description = "ListenBrainz submission client for MPD";
        after = [
          "network.target"
          "mpd.service"
        ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          LoadCredential = "token:${config.age.secrets.listenbrainz-token.path}";
          ExecStart = "${pkgs.listenbrainz-mpd}/bin/listenbrainz-mpd -c ${cfg}";
          Restart = "always";
        };
      };
  };

  users.users.mpd.extraGroups = [ "pipewire" ];

  age.secrets.listenbrainz-token.file = sharedSecrets + "/listenbrainz-token.age";

  # pbor.backup.fsBackups = {
  #   music = {
  #     paths = [
  #       "/storage/music"
  #       "/var/lib/mpd"
  #     ];
  #   };
  # };
}
