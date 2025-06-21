{
  config,
  machineSecrets,
  ...
}:
{
  pbor.webapps.apps = {
    shiori = {
      subDomain = "shiori";
      proxyTo = "http://127.0.0.1:8085";
      locations."/" = { };
      dashboard = {
        name = "Shiori";
        category = "app";
        icon = "shopping-bag";
      };
    };
  };

  services.shiori = {
    enable = true;
    address = "127.0.0.1";
    port = 8085;
  };

  systemd.services.shiori.serviceConfig.EnvironmentFile = [
    config.age.secrets.shiori-environment.path
  ];

  age.secrets.shiori-environment.file = machineSecrets + "/shiori-environment.age";

  pbor.backup.fsBackups.shiori = {
    paths = [
      "/var/lib/private/shiori"
    ];
  };
}
