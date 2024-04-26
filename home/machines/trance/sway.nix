{
  pkgs,
  config,
  ...
}: {
  wayland.windowManager.sway = {
    package = null;
    config = {
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in {
        "${modifier}+Shift+w" = ''exec networkmanager_dmenu'';
      };
      input = {
        "2362:628:PIXA3854:00_093A:0274_Touchpad" = {
          click_method = "clickfinger";
          natural_scroll = "enabled";
          dwt = "true";
          scroll_factor = "0.2";
        };
      };
      output = {
        "eDP-1" = {
          scale = "1.5";
        };
      };
      output = {
        "DP-4" = {
          scale = "2";
        };
      };
    };
    extraConfig = ''
      bindswitch --reload --locked lid:off output eDP-1 enable;
      bindswitch --reload --locked lid:on output eDP-1 disable;
    '';
  };

  programs.i3status-rust.bars.default = {
    blocks = [
      {
        block = "sound";
        driver = "pulseaudio";
        device_kind = "sink";
        format = "$output_name{ $volume|}";
        mappings = {
          "alsa_output.usb-Razer_Razer_USB_Sound_Card_00000000-00.analog-stereo" = "";
          "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
          "bluez_output.94_DB_56_88_F4_0E.1" = "";
        };
        click = [
          {
            button = "left";
            cmd = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          }
        ];
      }
      {
        block = "net";
        device = "wlan0";
        format = "$icon $signal_strength";
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
        block = "battery";
        driver = "sysfs";
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
  };
}
