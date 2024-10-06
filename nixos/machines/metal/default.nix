{
  config,
  pkgs,
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
      "/home/pbor/.local/share/password-store" = {
        id = "password-store";
        devices = ["rock"];
      };
      "/home/pbor/.local/share/synced-state" = {
        id = "synced-state";
        devices = ["rock"];
      };
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

    binfmt.registrations = {
      DOSWin = {
        interpreter = "${pkgs.wineWowPackages.waylandFull}/bin/wine64";
        magicOrExtension = "MZ";
        recognitionType = "magic";
      };
    };
  };

  environment.systemPackages = [
    config.boot.kernelPackages.perf
    pkgs.wineWowPackages.waylandFull
  ];

  programs = {
    adb.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
  users.users.pbor.extraGroups = ["adbusers" "kvm" "wireshark"];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    # Make sure keyboard interrupt doesn't abort suspend. ¯\_(ツ)_/¯ Linux is such a Linux
    powerDownCommands = ''
      sleep 0.1
    '';
  };

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    gnupg.sshKeyPaths = ["/etc/ssh/ssh_host_rsa_key"];

    secrets = {
      listenbrainz-mpd-token = {
        mode = "0400";
        owner = config.users.users.pbor.name;
        group = config.users.users.pbor.group;
      };
      taskwarrior-sync = {
        mode = "0400";
        owner = config.users.users.pbor.name;
        group = config.users.users.pbor.group;
      };
    };
  };

  services = {
    journald.extraConfig = ''
      SystemMaxUse=100M
    '';
    dbus.packages = [pkgs.gcr];
    udev.extraRules = ''
      # Disable wakeup from suspend by mouse movement/click
      ACTION=="add", ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="60e6", ATTR{power/wakeup}="disabled"
    '';
    udisks2.enable = true;
    flatpak.enable = true;
  };

  time.timeZone = "Europe/Amsterdam";
}
