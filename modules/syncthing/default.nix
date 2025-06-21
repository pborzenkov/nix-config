{
  config,
  lib,
  ...
}:
let
  cfg = config.pbor.syncthing;

  knownDevices = {
    # Main server
    rock = {
      id = "OVPKWLR-WWRZIQI-SYA6WDV-EZFXE5I-VCX27T7-IWONKV6-DH5MLFH-BUCCLQ4";
      addresses = [
        "tcp://192.168.88.11:22000"
        "dynamic"
      ];
    };
    # Desktop
    metal = {
      id = "52PIOYT-JNTOP7M-KEVFHVF-UO4DPFC-EHOJKNY-4DRHKLN-W2QI57L-TT7JSQX";
      addresses = [
        "tcp://192.168.88.12:22000"
        "dynamic"
      ];
    };
    # Laptop
    trance = {
      id = "UQA7VGD-ZWYO6AD-G7PFTZS-AE7QD4V-GGU6ECB-WD65QYR-DXMWQXU-4L5SDAL";
      addresses = [ "dynamic" ];
    };
    # Phone
    pixel9 = {
      id = "SIAH2E7-VLKE3L7-KGZRZVN-GY2TFI7-3ZOVMPN-Y6UKUGR-F34LKHS-KKT3YAX";
      addresses = [ "dynamic" ];
    };
  };
in
{
  options = {
    pbor.syncthing.enable = (lib.mkEnableOption "Enable Syncthing") // {
      default = config.pbor.enable;
    };
    pbor.syncthing.folders = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              path = lib.mkOption {
                type = lib.types.str;
                default = name;
              };

              id = lib.mkOption {
                type = lib.types.str;
              };

              type = lib.mkOption {
                type = lib.types.enum [
                  "sendreceive"
                  "sendonly"
                  "receiveonly"
                  "receiveencrypted"
                ];
                default = "sendreceive";
              };

              devices = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;

      user = "pbor";
      group = "users";
      configDir = "/home/pbor/.config/syncthing";
      dataDir = "/home/pbor/.local/share/syncthing";

      settings =
        let
          usedDevices = lib.unique (lib.flatten (lib.mapAttrsToList (_: f: f.devices) cfg.folders));
        in
        {
          devices = lib.filterAttrs (n: _: builtins.elem n usedDevices) knownDevices;
          folders = cfg.folders;
        };
    };
  };
}
