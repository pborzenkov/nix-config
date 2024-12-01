{config, ...}: {
  services.valheim = {
    enable = false;
    serverName = "Geest";
    worldName = "Geest";
    openFirewall = true;
    password = "\${SERVER_PASS}";
  };

  systemd.services.valheim.serviceConfig.EnvironmentFile = config.sops.secrets.valheim-environment.path;

  sops.secrets.valheim-environment = {};

  pbor.backup.fsBackups = {
    valheim = {
      paths = [
        "/var/lib/valheim/.config"
      ];
    };
  };
}
