{
  config,
  pkgs,
  ...
}: {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    systemWide = true;
    config.pipewire = {
      "context.modules" = [
        {
          name = "libpipewire-module-rt";
          args = {
            nice.level = -11;
          };
          flags = [
            "ifexists"
            "nofail"
          ];
        }
        {name = "libpipewire-module-protocol-native";}
        {name = "libpipewire-module-profiler";}
        {name = "libpipewire-module-metadata";}
        {name = "libpipewire-module-spa-device-factory";}
        {name = "libpipewire-module-spa-node-factory";}
        {name = "libpipewire-module-client-node";}
        {name = "libpipewire-module-client-device";}
        {
          name = "libpipewire-module-portal";
          flags = [
            "ifexists"
            "nofail"
          ];
        }
        {name = "libpipewire-module-access";}
        {name = "libpipewire-module-adapter";}
        {name = "libpipewire-module-link-factory";}
        {name = "libpipewire-module-session-manager";}
        {
          name = "libpipewire-module-x11-bell";
          args = {};
          flags = [
            "ifexists"
            "nofail"
          ];
        }

        {
          name = "libpipewire-module-raop-sink";
          args = {
            "raop.hostname" = "a7000.lab.borzenkov.net";
            "roap.port" = 7000;
            "node.description" = "Living Room";
            "raop.audio.codec" = "PCM";
            "raop.encryption.type" = "auth_setup";
            "raop.transport" = "udp";
            "device.model" = "HT-A7000";
            # "audio.format" = "S24_32";
            # "audio.rate" = 48000;
          };
        }
      ];
    };
  };

  users.users.pbor.extraGroups = ["pipewire"];
}
