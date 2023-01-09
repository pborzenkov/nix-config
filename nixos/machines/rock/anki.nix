{
  config,
  pkgs,
  ...
}: let
  cfg = {
    listen = {
      host = "127.0.0.1";
      port = 27701;
    };
    paths = {
      root_dir = "/var/lib/ankisyncd-rs";
    };
    encryption = {
      ssl_enable = false;
      cert_file = "";
      key_file = "";
    };
  };
in {
  webapps.apps.anki = {
    subDomain = "anki";
    proxyTo = "http://127.0.0.1:${toString cfg.listen.port}";
    locations."/" = {};
  };

  systemd.services.ankisyncd-rs = let
    cfg-toml = (pkgs.formats.toml {}).generate "config.toml" cfg;
  in {
    description = "ankisyncd-rs - Anki sync server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "ankisyncd-rs";
      ExecStart = "${pkgs.ankisyncd-rs}/bin/ankisyncd --config ${cfg-toml}";
      Restart = "always";
    };
  };

  backup.fsBackups.anki = {
    paths = [
      "/var/lib/ankisyncd-rs"
    ];
  };
}
