{...}: {
  services.taskchampion-sync-server = {
    enable = true;
    port = 8998;
  };

  pbor.webapps.apps.taskwarrior = {
    subDomain = "taskwarrior";
    locations."/" = {
      custom = {
        proxyPass = "http://127.0.0.1:8998";
      };
    };
  };

  pbor.backup.fsBackups.taskchampion-sync-server = {
    paths = [
      "/var/lib/taskchampion-sync-server"
    ];
  };
}
