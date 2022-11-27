{ config, pkgs, webapps, ... }:
let
  port = "8084";
in
{
  webapps.apps.photoprism = {
    subDomain = "photos";
    proxyTo = "http://127.0.0.1:${port}";
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

  systemd.services.photoprism = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "photoprism system service";

    serviceConfig = {
      User = "photoprism";
      Group = "photoprism";
      DynamicUser = true;
      Type = "simple";
      Restart = "on-failure";
      StateDirectory = "photoprism";
      ExecStart = "${pkgs.photoprism}/bin/photoprism start";
      EnvironmentFile = [ config.sops.secrets.photoprism-environment.path ];
    };

    environment = {
      PHOTOPRISM_AUTH_MODE = "password";

      PHOTOPRISM_LOG_LEVEL = "trace";
      PHOTOPRISM_ORIGINALS_PATH = "/storage/photos";
      PHOTOPRISM_STORAGE_PATH = "/var/lib/photoprism";
      PHOTOPRISM_IMPORT_PATH = "/var/lib/photoprism/import";
      PHOTOPRISM_ASSETS_PATH = "${pkgs.photoprism}/share/photoprism";

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

      PHOTOPRISM_HTTP_COMPRESSION = "none";
      PHOTOPRISM_HTTP_PORT = port;

      PHOTOPRISM_DARKTABLE_BIN = "${pkgs.darktable}/bin/darktable";
      PHOTOPRISM_RAWTHERAPEE_BIN = "${pkgs.rawtherapee}/bin/rawtherapee";
      PHOTOPRISM_HEIFCONVERT_BIN = "${pkgs.libheif}/bin/heif-convert";
      PHOTOPRISM_FFMPEG_BIN = "${pkgs.ffmpeg}/bin/ffmpeg";
      PHOTOPRISM_EXIFTOOL_BIN = "${pkgs.exiftool}/bin/exiftool";
    };

    unitConfig = {
      RequiresMountsFor = [ "/storage" ];
    };
  };

  sops.secrets.photoprism-environment = { };

  backup.fsBackups = {
    photos = {
      paths = [
        "/storage/photos"
      ];
    };
  };
}
