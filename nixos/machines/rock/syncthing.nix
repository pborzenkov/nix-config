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
        id = "ZJ2IFF7-HCYBH2T-SONJZXN-B3LOL3M-L6XM33H-M5UQ2S3-6PNIVLI-MI2JJAE";
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

      # Android phone
      phone = {
        id = "YY6DZ4F-BSMXRSE-VOIAU2D-5BEXYIH-CGJGIN7-EU7QMBY-PDZ7UQ2-M3UXYQQ";
        addresses = [
          "dynamic"
        ];
      };

      # Work laptop
      trance = {
        id = "UQA7VGD-ZWYO6AD-G7PFTZS-AE7QD4V-GGU6ECB-WD65QYR-DXMWQXU-4L5SDAL";
        addresses = [
          "dynamic"
        ];
      };
    };

    folders = {
      "/home/pbor/docs" = {
        id = "docs";
        devices = ["metal" "trance"];
      };

      "/home/pbor/books" = {
        id = "books";
        devices = ["metal" "trance"];
      };

      "/home/pbor/.local/share/password-store" = {
        id = "password-store";
        devices = ["jazz" "metal" "phone" "trance"];
      };

      "/home/pbor/.local/share/photos-for-review" = {
        id = "photos";
        type = "receiveonly";
        devices = ["metal" "phone"];
      };
    };
  };
}
