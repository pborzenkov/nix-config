{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;

    user = "pbor";
    group = "users";
    configDir = "/home/pbor/.config/syncthing";
    dataDir = "/home/pbor/.local/share/syncthing";

    devices = {
      # Old MacBook
      phobos = {
        id = "NCWMUCL-JCC5VJV-KRMEZWU-UALTJYJ-CDNQ4RQ-GGLUEGR-CQZTJU3-2A3KIQ2";
        addresses = [
          "tcp://phobos.lab.pborzenkov.net:22000"
          "dynamic"
        ];
      };

      # Windows desktop
      jazz = {
        id = "BIDWFHH-NHSNIH3-ICQGA5H-YXSCYSE-7C6IA4D-NF5Y46K-I3YsVLR-OXKAQAA";
        addresses = [
          "dynamic"
        ];
      };

      # Booking.com laptop
      booking-laptop = {
        id = "GF7I7ZP-73IOOMA-W2A54EB-ICD6C2B-LYFNFNX-PALHQBS-MTJNOHK-BT5BRQA";
        addresses = [
          "dynamic"
        ];
      };

      # Android phone
      phone = {
        id = "YY6DZ4F-BSMXRSE-VOIAU2D-5BEXYIH-CGJGIN7-EU7QMBY-PDZ7UQ2-M3UXYQQ";
        addresses = [
          "dynamic"
        ];
      };
    };

    folders = {
      "/home/pbor/docs" = {
        id = "docs";
        devices = [ "phobos" ];
      };

      "/home/pbor/books" = {
        id = "books";
        devices = [ "phobos" ];
      };

      "/home/pbor/.local/share/password-store" = {
        id = "password-store";
        devices = [ "phobos" "jazz" "booking-laptop" "phone" ];
      };
    };
  };
}
