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

    # TODO:
    torrents.enable = false;
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

  users.users.pbor.extraGroups = ["kvm"];

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
}
