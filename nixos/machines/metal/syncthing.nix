{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;

    user = "pbor";
    group = "users";
    configDir = "/home/pbor/.config/syncthing";
    dataDir = "/home/pbor/.local/share/syncthing";

    devices = {
      rock = {
        id = "OVPKWLR-WWRZIQI-SYA6WDV-EZFXE5I-VCX27T7-IWONKV6-DH5MLFH-BUCCLQ4";
        addresses = [
          "tcp://rock.lab.borzenkov.net:22000"
          "dynamic"
        ];
      };
    };

    folders = {
      "/home/pbor/docs" = {
        id = "docs";
        devices = [ "rock" ];
      };

      "/home/pbor/books" = {
        id = "books";
        devices = [ "rock" ];
      };

      "/home/pbor/.local/share/password-store" = {
        id = "password-store";
        devices = [ "rock" ];
      };
    };
  };
}
