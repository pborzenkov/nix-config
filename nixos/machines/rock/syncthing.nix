{
  config,
  pkgs,
  ...
}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    user = "pbor";
    group = "users";
    configDir = "/home/pbor/.config/syncthing";
    dataDir = "/home/pbor/.local/share/syncthing";

    devices = {
      # Windows desktop
      jazz = {
        id = "BIDWFHH-NHSNIH3-ICQGA5H-YXSCYSE-7C6IA4D-NF5Y46K-I3YsVLR-OXKAQAA";
        addresses = [
          "dynamic"
        ];
      };

      # Linux desktop
      metal = {
        id = "52PIOYT-JNTOP7M-KEVFHVF-UO4DPFC-EHOJKNY-4DRHKLN-W2QI57L-TT7JSQX";
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
        devices = ["metal"];
      };

      "/home/pbor/books" = {
        id = "books";
        devices = ["metal"];
      };

      "/home/pbor/.local/share/password-store" = {
        id = "password-store";
        devices = ["jazz" "metal" "booking-laptop" "phone"];
      };

      "/home/pbor/.local/share/photos-for-review" = {
        id = "photos";
        type = "receiveonly";
        devices = ["metal" "phone"];
      };
    };
  };
}
