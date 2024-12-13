{...}: {
  pbor.webapps.apps.bitwarden = {
    subDomain = "bitwarden";
    proxyTo = "http://127.0.0.1:8222";
    locations."/" = {};
    dashboard = {
      name = "Bitwarden";
      category = "app";
      icon = "lock";
    };
  };

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://bitwarden.lab.borzenkov.net";

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SIGNUPS_ALLOWED = false;
    };
    dbBackend = "sqlite";
    backupDir = "/var/backup/vaultwarden";
  };

  pbor.backup.fsBackups.bitwarden = {
    paths = [
      "/var/backup/vaultwarden"
    ];
  };
}
