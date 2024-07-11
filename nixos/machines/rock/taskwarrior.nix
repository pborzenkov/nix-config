{pkgs, ...}: {
  systemd.services.taskchampion-sync-server = {
    description = "Sync server for Taskwarrior 3";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "taskchampion-sync-server";
      ExecStart = ''
        ${pkgs.taskchampion-sync-server}/bin/taskchampion-sync-server \
          -p 8998 \
          -d /var/lib/taskchampion-sync-server
      '';
      Restart = "always";
      RestartSec = 5;
    };
  };

  webapps.apps.taskwarrior = {
    subDomain = "taskwarrior";
    locations."/" = {
      custom = {
        proxyPass = "http://127.0.0.1:8998";
      };
    };
  };

  backup.fsBackups.taskchampion-sync-server = {
    paths = [
      "/var/lib/taskchampion-sync-server"
    ];
  };
}
