{
  pkgs,
  inputs,
  ...
}: {
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
      "/home/pbor/notes" = {
        id = "notes";
        devices = ["rock"];
      };
      "/home/pbor/.local/share/synced-state" = {
        id = "synced-state";
        devices = ["rock"];
      };
    };
    wm = {
      hyprland = {
        monitors = [
          "desc:Dell Inc. DELL U3219Q 692P413, 3840x2160, 0x0, 2"
          "desc:LG Electronics LG TV 0x01010101,disable"
        ];
        workspace-rules = [
          "name:sunshine, monitor:desc:LG Electronics LG TV 0x01010101, default:true"
        ];
        waybar.pulseaudio-icons = {
          "alsa_output.usb-HP__Inc_HyperX_Cloud_Alpha_Wireless_00000001-00.analog-stereo" = "";
          "alsa_output.usb-EDIFIER_EDIFIER_G2000_EDI00000X07-01.analog-stereo" = "";
          "alsa_output.pci-0000_10_00.1.hdmi-stereo-extra4" = "";
        };
      };
    };

    devtools = {
      android.enable = true;
      lang.c.enable = true;
    };

    media.audio.whisper.rocm = true;

    ssh.server.enable = true;
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
      "usbcore.autosuspend=-1"
    ];
    supportedFilesystems = ["ntfs"];
  };
  hardware.display = {
    edid.packages = [
      (pkgs.runCommandLocal "lg-tv-edid" {} ''
        mkdir -p "$out/lib/firmware/edid"
        cp ${inputs.self}/assets/lg-tv.edid "$out/lib/firmware/edid/lg-tv.bin"
      '')
    ];
    outputs."HDMI-A-1" = {
      edid = "lg-tv.bin";
      mode = "e";
    };
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
  };

  time.timeZone = "Europe/Amsterdam";
  services.timesyncd.servers = [
    "0.nl.pool.ntp.org"
    "1.nl.pool.ntp.org"
    "2.nl.pool.ntp.org"
    "3.nl.pool.ntp.org"
  ];
}
