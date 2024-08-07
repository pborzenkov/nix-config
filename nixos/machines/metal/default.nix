{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    inputs.sops-nix.nixosModules.sops

    ../../podman.nix

    ./login.nix
    ./nix.nix
    ./sound.nix
    ./syncthing.nix
  ];

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
      "memmap=0x8000$0x5044C0000,0x8000$0x5064C0000,0x1000$0x5AF794000,0x5000$0xA5D890,0x8000$0xA5F890000,0x1000$0xD2E85F000" # disable bad RAM
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

  fileSystems."/storage" = {
    device = "helios64.lab.borzenkov.net:/storage";
    fsType = "nfs";
  };

  hardware = {
    enableRedistributableFirmware = true;
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = [
      pkgs.corefonts
      pkgs.nerdfonts
      pkgs.font-awesome_5
    ];
    fontconfig = {
      enable = true;
    };
  };

  networking = {
    hostName = "metal";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        9090 # Calibre sync server
        3000
      ];
      allowedUDPPorts = [
        5678 # Mikrotik NDP
        37008 # traffic sniffer on Mikrotik
      ];
      extraCommands = ''
        # Mikrotik MAC Telnet
        iptables -A INPUT -p udp --sport 20561 -j ACCEPT
      '';
    };
    useDHCP = false;
    dhcpcd.enable = false;
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;
    networks."40-wired" = {
      name = "enp8s0";
      DHCP = "ipv4";
      networkConfig = {
        LinkLocalAddressing = "no";
      };
      dhcpV4Config = {
        UseDomains = true;
      };
    };
  };

  programs = {
    adb.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    steam.enable = true;
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
    resolved.enable = true;
    journald.extraConfig = ''
      SystemMaxUse=100M
    '';
    dbus.packages = [pkgs.gcr];
    udev.extraRules = ''
      # Disable wakeup from suspend by mouse movement/click
      ACTION=="add", ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="60e6", ATTR{power/wakeup}="disabled"
    '';
    udisks2.enable = true;
  };

  xdg.portal.enable = true;

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "23.05";
}
