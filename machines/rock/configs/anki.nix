{config, ...}: {
  pbor.webapps.apps.anki = {
    subDomain = "anki";
    proxyTo = "http://127.0.0.1:${toString config.services.anki-sync-server.port}";
    locations."/" = {};
  };

  services.anki-sync-server = {
    enable = true;
    address = "127.0.0.1";
    users = [
      {
        username = "pavel@borzenkov.net";
        passwordFile = config.sops.secrets.anki-sync-server.path;
      }
    ];
  };

  sops.secrets.anki-sync-server = {};

  pbor.backup.fsBackups.anki = {
    paths = [
      "/var/lib/private/anki-sync-server"
    ];
  };
}
