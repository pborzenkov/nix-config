{...}: {
  services.taskserver = {
    enable = true;
    fqdn = "taskserver.lab.borzenkov.net";
    listenHost = "::";
    openFirewall = true;
    organisations = {
      personal = {
        users = ["pavel"];
      };
    };
  };

  backup.fsBackups.lldap = {
    paths = [
      "/var/lib/taskserver"
    ];
  };
}
