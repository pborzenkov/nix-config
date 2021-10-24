{ config, pkgs, ... }:
{
  virtualisation.oci-containers.containers.valheim = {
    image = "lloesche/valheim-server";
    ports = [
      "2456-2457:2456-2457/udp"
    ];
    volumes = [
      "/var/lib/valheim/config:/config"
      "/var/lib/valheim/data:/opt/valheim"
    ];
    extraOptions = [
      "--cap-add=sys_nice"
      "--stop-timeout=120"
    ];
    environment = {
      ADMINLIST_IDS = "76561198024953952 76561198076862723";
      SERVER_NAME = "Westeros";
      WORLD_NAME = "Westeros";
      SERVER_PUBLIC = "false";
      BACKUPS = "false";
    };
    environmentFiles = [
      config.sops.secrets.valheim-environment.path
    ];
  };

  networking.firewall.allowedUDPPorts = [ 2456 2457 ];

  sops.secrets.valheim-environment = { };

  backup.fsBackups = {
    valheim = {
      paths = [
        "/var/lib/valheim/config"
      ];
    };
  };
}
