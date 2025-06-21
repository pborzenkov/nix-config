{ config, ... }:
let
  homeConfig = {
    title = "Dashboard";
    header = false;
    footer = false;
    connectivityCheck = false;
    colums = "auto";
    services = config.lib.pbor.webapps.homerServices ++ [
      {
        name = "Network";
        items = [
          {
            name = "Router";
            icon = "fas fa-network-wired";
            url = "http://router.mk.lab.borzenkov.net";
            target = "_blank";
          }
          {
            name = "Living Room";
            icon = "fas fa-wifi";
            url = "http://living-room.mk.lab.borzenkov.net";
            target = "_blank";
          }
          {
            name = "Bedroom";
            icon = "fas fa-wifi";
            url = "http://bedroom.mk.lab.borzenkov.net";
            target = "_blank";
          }
          {
            name = "Attic";
            icon = "fas fa-wifi";
            url = "http://attic.mk.lab.borzenkov.net";
            target = "_blank";
          }
          {
            name = "Garage";
            icon = "fas fa-wifi";
            url = "http://garage.mk.lab.borzenkov.net";
            target = "_blank";
          }
        ];
      }
    ];
  };
in
{
  pbor.webapps = {
    dashboardCategories = [
      {
        name = "Applications";
        tag = "app";
      }
      {
        name = "Infrastructure";
        tag = "infra";
      }
      {
        name = "Arrs";
        tag = "arr";
      }
    ];
    apps = {
      dashboard = {
        subDomain = "dashboard";
      };
    };
  };

  services.homer = {
    enable = true;
    virtualHost = {
      nginx.enable = true;
      domain = "dashboard.${config.pbor.webapps.domain}";
    };
    settings = homeConfig;
  };
}
