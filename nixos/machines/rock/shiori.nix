{...}: {
  services = {
    shiori = {
      enable = true;
      address = "127.0.0.1";
      port = 8085;
    };
  };

  webapps.apps = {
    shiori = {
      subDomain = "shiori";
      proxyTo = "http://127.0.0.1:8085";
      locations."/" = {};
      dashboard = {
        name = "Shiori";
        category = "app";
        icon = "shopping-bag";
      };
    };
  };

  backup.fsBackups.shiori = {
    paths = [
      "/var/lib/shiori"
    ];
  };
}
