{config, ...}: {
  services.valheim = {
    enable = true;
    serverName = "Geest";
    worldName = "Geest";
    openFirewall = true;
    password = "\${SERVER_PASS}";
  };

  systemd.services.valheim.serviceConfig.EnvironmentFile = config.sops.secrets.valheim-environment.path;

  sops.secrets.valheim-environment = {};

  backup.fsBackups = {
    valheim = {
      paths = [
        "/var/lib/valheim/config"
      ];
    };
  };
}
