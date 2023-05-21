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

    settings = {
      devices = {
        # Linux server
        rock = {
          id = "OVPKWLR-WWRZIQI-SYA6WDV-EZFXE5I-VCX27T7-IWONKV6-DH5MLFH-BUCCLQ4";
          addresses = [
            "tcp://rock.lab.borzenkov.net:22000"
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
          devices = ["rock"];
        };

        "/home/pbor/books" = {
          id = "books";
          devices = ["rock"];
        };

        "/home/pbor/.local/share/password-store" = {
          id = "password-store";
          devices = ["rock"];
        };

        "/home/pbor/.local/share/photos-for-review" = {
          id = "photos";
          devices = ["rock"];
        };
      };
    };
  };
}
