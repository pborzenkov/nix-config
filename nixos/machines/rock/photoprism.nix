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

  virtualisation.oci-containers.containers.photoprism = {
    image = "photoprism/photoprism:220730-bullseye";
    ports = [
      "${port}:${port}"
    ];
    volumes = [
      "/storage/photos:/photoprism/originals"
      "/var/lib/photoprism:/photoprism/storage"
    ];
    extraOptions = [
      "--security-opt"
      "seccomp=unconfined"
      "--security-opt"
      "apparmor=unconfined"
    ];
    environment = {
      PHOTOPRISM_HTTP_PORT = port; # Built-in Web server port
      PHOTOPRISM_HTTP_COMPRESSION = "gzip"; # Improves transfer speed and bandwidth utilization (none or gzip)
      PHOTOPRISM_DEBUG = "false"; # Run in debug mode (shows additional log messages)
      PHOTOPRISM_PUBLIC = "false"; # No authentication required (disables password protection)
      PHOTOPRISM_READONLY = "false"; # Don't modify originals directory (reduced functionality)
      PHOTOPRISM_EXPERIMENTAL = "true"; # Enables experimental features
      PHOTOPRISM_DISABLE_WEBDAV = "false"; # Disables built-in WebDAV server
      PHOTOPRISM_DISABLE_SETTINGS = "false"; # Disables Settings in Web UI
      PHOTOPRISM_DISABLE_TENSORFLOW = "false"; # Disables using TensorFlow for image classification
      PHOTOPRISM_DARKTABLE_PRESETS = "false"; # Enables Darktable presets and disables concurrent RAW conversion
      PHOTOPRISM_DETECT_NSFW = "false"; # Flag photos as private that MAY be offensive (requires TensorFlow)
      PHOTOPRISM_UPLOAD_NSFW = "true"; # Allow uploads that MAY be offensive
      PHOTOPRISM_DISABLE_BACKUPS = "true"; # Disable backups

      PHOTOPRISM_SITE_URL = "https://${config.webapps.apps.photoprism.subDomain}.${config.webapps.domain}";
      PHOTOPRISM_SITE_TITLE = "PhotoPrism";
      PHOTOPRISM_SITE_CAPTION = "Pavel's Photos";
      PHOTOPRISM_SITE_DESCRIPTION = "Pavel's Photos";
      PHOTOPRISM_SITE_AUTHOR = "Pavel Borzenkov";
    };
    environmentFiles = [
      config.sops.secrets.photoprism-environment.path
    ];
  };

  systemd.services.docker-photoprism.unitConfig.RequiresMountsFor = [ "/storage" ];

  sops.secrets.photoprism-environment = { };

  backup.fsBackups = {
    photos = {
      paths = [
        "/storage/photos"
      ];
    };
  };
}
