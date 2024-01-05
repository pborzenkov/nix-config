{config, ...}: {
  webapps.apps.photoprism = {
    subDomain = "photos";
    proxyTo = "http://127.0.0.1:8084";
    locations."/" = {
      custom = {
        proxyWebsockets = true;
      };
    };
    dashboard = {
      name = "PhotoPrism";
      category = "app";
      icon = "camera";
    };
  };

  services.photoprism = {
    enable = true;
    address = "127.0.0.1";
    port = 8084;
    passwordFile = config.sops.secrets.photoprism.path;
    importPath = "/var/lib/photoprism/import";
    originalsPath = "/storage/photos";
    storagePath = "/var/lib/photoprism";
    settings = {
      PHOTOPRISM_AUTH_MODE = "password";
      PHOTOPRISM_LOG_LEVEL = "info";
      PHOTOPRISM_READONLY = "false";
      PHOTOPRISM_EXPERIMENTAL = "true";
      PHOTOPRISM_DISABLE_WEBDAV = "false";
      PHOTOPRISM_DISABLE_SETTINGS = "false";
      PHOTOPRISM_DISABLE_PLACES = "false";
      PHOTOPRISM_DISABLE_BACKUPS = "true";
      PHOTOPRISM_DISABLE_TENSORFLOW = "false";
      PHOTOPRISM_DISABLE_FACES = "false";
      PHOTOPRISM_DISABLE_CLASSIFICATION = "false";
      PHOTOPRISM_DISABLE_FFMPEG = "false";
      PHOTOPRISM_DISABLE_EXIFTOOL = "false";
      PHOTOPRISM_DISABLE_HEIFCONVERT = "false";
      PHOTOPRISM_DISABLE_DARKTABLE = "false";
      PHOTOPRISM_DISABLE_RAWTHERAPEE = "false";
      PHOTOPRISM_DISABLE_RAW = "false";
      PHOTOPRISM_RAW_PRESETS = "true";
      PHOTOPRISM_EXIF_BRUTEFORCE = "true";
      PHOTOPRISM_DETECT_NSFW = "false";
      PHOTOPRISM_UPLOAD_NSFW = "true";
      PHOTOPRISM_SITE_URL = "https://${config.webapps.apps.photoprism.subDomain}.${config.webapps.domain}";
      PHOTOPRISM_SITE_AUTHOR = "Pavel Borzenkov";
      PHOTOPRISM_SITE_TITLE = "PhotoPrism";
      PHOTOPRISM_SITE_CAPTION = "Pavel's Photos";
      PHOTOPRISM_SITE_DESCRIPTION = "Pavel's Photos";
    };
  };

  systemd.services.photoprism.unitConfig.RequiresMountsFor = ["/storage"];

  sops.secrets.photoprism = {};

  backup.fsBackups = {
    photos = {
      paths = [
        "/storage/photos"
      ];
    };
  };
}
