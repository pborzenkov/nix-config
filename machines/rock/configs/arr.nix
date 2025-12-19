{ lib, ... }:
{
  services = {
    bazarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
    jellyseerr.enable = true;
  };

  systemd.services = lib.genAttrs [ "bazarr" "radarr" "sonarr" ] (name: {
    serviceConfig.SupplementaryGroups = [ "storage" ];
    unitConfig.RequiresMountsFor = [ "/storage" ];
  });

  pbor.webapps.apps = {
    bazarr = {
      subDomain = "bazarr";
      auth.rbac = [ "group:arr_admin" ];
      proxyTo = "http://127.0.0.1:6767";
      locations."/" = { };
      dashboard = {
        name = "Bazaar";
        category = "arr";
        icon = "indent";
      };
    };
    prowlarr = {
      subDomain = "prowlarr";
      auth.rbac = [ "group:arr_admin" ];
      proxyTo = "http://127.0.0.1:9696";
      locations."/" = { };
      dashboard = {
        name = "Prowlarr";
        category = "arr";
        icon = "indent";
      };
    };
    radarr = {
      subDomain = "radarr";
      auth.rbac = [ "group:arr_admin" ];
      proxyTo = "http://127.0.0.1:7878";
      locations."/" = { };
      dashboard = {
        name = "Radarr";
        category = "arr";
        icon = "indent";
      };
    };
    sonarr = {
      subDomain = "sonarr";
      auth.rbac = [ "group:arr_admin" ];
      proxyTo = "http://127.0.0.1:8989";
      locations."/" = { };
      dashboard = {
        name = "Sonaar";
        category = "arr";
        icon = "indent";
      };
    };
    jellyseerr = {
      subDomain = "jellyseerr";
      proxyTo = "http://127.0.0.1:5055";
      locations."/" = { };
      dashboard = {
        name = "Jellyseerr";
        category = "arr";
        icon = "indent";
      };
    };
  };

  pbor.backup.fsBackups.arr = {
    paths = [
      "/var/lib/bazarr"
      "/var/lib/prowlarr"
      "/var/lib/radarr"
      "/var/lib/sonarr"
      "/var/lib/jellyseerr"
    ];
  };
}
