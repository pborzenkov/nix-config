{
  pkgs,
  ...
}:
{
  services.calibre-web = {
    enable = true;
    package = pkgs.calibre-web.overridePythonAttrs (old: {
      dependencies = old.dependencies ++ old.optional-dependencies.kobo ++ old.optional-dependencies.ldap;
    });
    listen = {
      ip = "127.0.0.1";
      port = 8084;
    };
    options = {
      enableBookConversion = true;
      enableBookUploading = true;
      enableKepubify = true;
      calibreLibrary = "/storage/books";
      reverseProxyAuth = {
        enable = true;
        header = "Remote-User";
      };
    };
  };

  systemd.services.calibre-web.unitConfig.RequiresMountsFor = [ "/storage" ];

  pbor.webapps.apps.calibre = {
    subDomain = "calibre";
    auth.rbac = [ "group:books" ];
    proxyTo = "http://127.0.0.1:8084";
    locations."/" = { };
    locations."/opds" = {
      skip_auth = true;
    };
    dashboard = {
      name = "Calibre";
      category = "app";
      icon = "book";
    };
  };

  pbor.backup.fsBackups = {
    books = {
      paths = [
        "/storage/books"
      ];
    };
  };
}
