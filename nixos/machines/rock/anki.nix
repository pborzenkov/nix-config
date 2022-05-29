{ config, pkgs, ... }:

{
  webapps.apps.anki = {
    subDomain = "anki";
    proxyTo = "http://127.0.0.1:${toString config.services.ankisyncd.port}";
    locations."/" = { };
  };

  services.ankisyncd = {
    enable = true;
    host = "127.0.0.1";
  };

  backup.fsBackups.anki = {
    paths = [
      "/var/lib/ankisyncd"
    ];
  };
}
