{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.pbor.wm.i3status;
in {
  options = {
    pbor.wm.i3status.enable = (lib.mkEnableOption "Enable i3status-rust") // {default = config.pbor.wm.enable;};
    pbor.wm.i3status.sound_mappings = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
      default = null;
      description = ''Sound device mappings.'';
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {config, ...}: {
      programs.i3status-rust = {
        enable = true;
        bars.default = {
          blocks = [
            {
              block = "sound";
              driver = "pulseaudio";
              device_kind = "sink";
              format = "$output_name{ $volume|}";
              mappings = lib.mkIf (!isNull cfg.sound_mappings) cfg.sound_mappings;
              click = [
                {
                  button = "left";
                  cmd = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
                }
              ];
            }
            {
              block = "keyboard_layout";
              driver = "sway";
              format = "$layout";
              mappings = {
                "English (US)" = "EN";
                "Russian (N/A)" = "RU";
              };
            }
            {
              block = "time";
              interval = 60;
              format = "$icon $timestamp.datetime(f:'%a %d/%m %R')";
            }
            {
              block = "notify";
            }
          ];

          settings = {
            icons = lib.mkForce {
              icons = "awesome6";
            };
            theme = {
              theme = "native"; # fully overwritten
              overrides =
                config.lib.stylix.i3status-rust.bar
                // {
                  idle_bg = config.lib.stylix.colors.withHashtag.base01;
                };
            };
          };
        };
      };
    };
  };
}
