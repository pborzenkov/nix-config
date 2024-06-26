{
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    pkgs.swaylock
  ];

  systemd.user.services.swayidle.Service = {
    Environment = lib.mkForce ["PATH=${dirOf pkgs.stdenv.shell}:${pkgs.swaylock}/bin:/usr/bin"];
    ExecStart = lib.mkForce "${pkgs.swayidle}/bin/swayidle -w";
  };

  wayland.windowManager.sway = {
    config = {
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
      {
        block = "notify";
      }
    ];
  };
}
