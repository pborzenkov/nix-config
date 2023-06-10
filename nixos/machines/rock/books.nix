{
  config,
  lib,
  pkgs,
  ...
}: {
  services.calibre-server = {
    enable = true;
    libraries = ["/storage/books"];
  };

  systemd.services.calibre-server = {
    serviceConfig.ExecStart = lib.mkForce ''
      ${pkgs.calibre}/bin/calibre-server \
      --enable-auth \
      --port 9876 \
      ${lib.concatStringsSep " " config.services.calibre-server.libraries} \
    '';
    unitConfig.RequiresMountsFor = ["/storage"];
  };

  webapps.apps.calibre = {
    subDomain = "calibre";
    proxyTo = "http://127.0.0.1:9876";
    locations."/" = {};
  };

  backup.fsBackups = {
    books = {
      paths = [
        "/storage/books"
      ];
    };
  };
}
