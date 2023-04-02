{
  pkgs,
  config,
  ...
}: let
  cfg = config.wayland.windowManager.sway;
in {
  wayland.windowManager.sway = {
    config = {
      keybindings = {
        "${cfg.config.modifier}+Shift+s" = ''
          exec rofi -theme-str 'window {width: 20%;} listview{scrollbar: false; lines: 6;}' \
          -show power \
          -modi "power:${pkgs.nur.repos.pborzenkov.rofi-power-menu}/bin/rofi-power-menu --choices lockscreen/logout/reboot/shutdown/suspend/windows"
        '';
      };
      output = {
        "DP-2" = {
          scale = "2";
        };
      };
    };
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
          "alsa_output.pci-0000_12_00.4.analog-stereo" = "";
          "alsa_output.pci-0000_10_00.1.hdmi-stereo-extra4" = "";
        };
        click = [
          {
            button = "left";
            cmd = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
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
    ];
  };
}
