{
  # config,
  # machineSecrets,
  ...
}:
{
  # services.valheim = {
  #   enable = false;
  #   serverName = "Geest";
  #   worldName = "Geest";
  #   openFirewall = true;
  #   password = "\${SERVER_PASS}";
  # };

  # systemd.services.valheim.serviceConfig.EnvironmentFile =
  #   config.age.secrets.valheim-environment.path;

  # age.secrets.valheim-environment.file = machineSecrets + "/valheim-environment.age";

  pbor.backup.fsBackups = {
    valheim = {
      paths = [
        "/var/lib/valheim/.config"
      ];
    };
  };
}
