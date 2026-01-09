{ pkgs, ... }:
{
  pbor = {
    sound.enable = true;

    syncthing.folders = {
      "/home/pbor/docs" = {
        id = "docs";
        devices = [
          "metal"
          "trance"
        ];
      };
      "/fast-storage/books" = {
        id = "books";
        devices = [
          "metal"
          "trance"
        ];
      };
      "/home/pbor/notes" = {
        id = "notes";
        devices = [
          "metal"
          "pixel9"
        ];
      };
      "/home/pbor/.local/share/synced-state" = {
        id = "synced-state";
        devices = [
          "metal"
          "trance"
        ];
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
      "drivetemp"
    ];
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  time.timeZone = "Europe/Amsterdam";
  services.timesyncd.servers = [
    "0.nl.pool.ntp.org"
    "1.nl.pool.ntp.org"
    "2.nl.pool.ntp.org"
    "3.nl.pool.ntp.org"
  ];

  services.fwupd.enable = true;

  systemd.services.ryzenadj = {
    description = "RyzenAdj";
    after = [ "sysinit.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = pkgs.writeShellScript "ryzenadj" ''
        ${pkgs.ryzenadj}/bin/ryzenadj -a 120000
        ${pkgs.ryzenadj}/bin/ryzenadj -b 160000
        ${pkgs.ryzenadj}/bin/ryzenadj -c 140000
      '';
    };
  };
}
