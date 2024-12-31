{pkgs, ...}: {
  pbor = {
    syncthing.folders = {
      "/home/pbor/docs" = {
        id = "docs";
        devices = ["metal" "trance"];
      };

      "/storage/books" = {
        id = "books";
        devices = ["metal" "trance"];
      };

      "/home/pbor/.local/share/password-store" = {
        id = "password-store";
        devices = ["metal" "trance" "pixel9"];
      };

      "/home/pbor/.local/share/synced-state" = {
        id = "synced-state";
        devices = ["metal" "trance"];
      };
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 5;

        memtest86.enable = true;
      };
      timeout = 1;

      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "nct6775"
    ];
    supportedFilesystems = ["ntfs"];
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=100M
  '';

  time.timeZone = "Europe/Amsterdam";
  services.timesyncd.servers = [
    "0.nl.pool.ntp.org"
    "1.nl.pool.ntp.org"
    "2.nl.pool.ntp.org"
    "3.nl.pool.ntp.org"
  ];
}
