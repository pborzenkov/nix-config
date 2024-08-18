{...}: {
  pbor = {
    wofi.menu = {
      windows = {
        title = "Reboot to Windows";
        cmd = "sudo systemctl reboot --boot-loader-entry auto-windows";
        icon = "";
      };
    };
    wm = {
      sway.output = {
        "DP-2" = {
          scale = "2";
        };
      };
      i3status.sound_mappings = {
        "alsa_output.usb-Razer_Razer_USB_Sound_Card_00000000-00.analog-stereo" = "";
        "alsa_output.pci-0000_12_00.4.analog-stereo" = "";
        "alsa_output.pci-0000_10_00.1.hdmi-stereo-extra4" = "";
      };
    };

    devtools = {
      lang.c.enable = true;
    };
  };
}
