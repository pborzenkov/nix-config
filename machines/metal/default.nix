{pkgs, ...}: {
  pbor = {
    syncthing.folders = {
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
      "/home/pbor/.local/share/synced-state" = {
        id = "synced-state";
        devices = ["rock"];
      };
    };
    wm = {
      sway = {
        output = {
          "DP-2" = {
            scale = "2";
          };
        };
        i3status.sound_mappings = {
          "alsa_output.usb-HP__Inc_HyperX_Cloud_Alpha_Wireless_00000001-00.analog-stereo" = "";
          "alsa_output.usb-EDIFIER_EDIFIER_G2000_EDI00000X07-01.analog-stereo" = "";
          "alsa_output.pci-0000_10_00.1.hdmi-stereo-extra4" = "";
        };
      };
      hyprland = {
        monitors = [
          "desc:Dell Inc. DELL U3219Q 692P413, 3840x2160, 0x0, 2"
        ];
        waybar.pulseaudio-icons = {
          "alsa_output.usb-HP__Inc_HyperX_Cloud_Alpha_Wireless_00000001-00.analog-stereo" = "";
          "alsa_output.usb-EDIFIER_EDIFIER_G2000_EDI00000X07-01.analog-stereo" = "";
          "alsa_output.pci-0000_10_00.1.hdmi-stereo-extra4" = "";
        };
      };
    };

    devtools = {
      lang.c.enable = true;
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 3;

        memtest86.enable = true;
      };
      timeout = 1;

      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
    ];
    supportedFilesystems = ["ntfs"];
  };

  users.users.pbor.extraGroups = ["dialout"];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    # Make sure keyboard interrupt doesn't abort suspend. ¯\_(ツ)_/¯ Linux is such a Linux
    powerDownCommands = ''
      sleep 0.1
    '';
  };

  services = {
    journald.extraConfig = ''
      SystemMaxUse=100M
    '';
    udev.extraRules = ''
      # Disable wakeup from suspend by mouse movement/click
      ACTION=="add", ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="60e6", ATTR{power/wakeup}="disabled"
    '';
    udisks2.enable = true;
    flatpak.enable = true;
  };

  time.timeZone = "Europe/Amsterdam";
  services.timesyncd.servers = [
    "0.nl.pool.ntp.org"
    "1.nl.pool.ntp.org"
    "2.nl.pool.ntp.org"
    "3.nl.pool.ntp.org"
  ];
}
