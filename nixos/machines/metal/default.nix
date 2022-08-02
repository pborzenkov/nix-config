{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../docker.nix

    ./login.nix
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

    kernelPackages = pkgs.linuxPackages_5_18;
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
    ];
    supportedFilesystems = [ "ntfs" ];

    binfmt.registrations = {
      DOSWin = {
        interpreter = "${pkgs.wine}/bin/wine";
        magicOrExtension = "MZ";
        recognitionType = "magic";
      };
    };
  };

  fileSystems."/storage" = {
    device = "helios64.lab.borzenkov.net:/storage";
    fsType = "nfs";
  };

  hardware.enableRedistributableFirmware = true;

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;
    fonts = [
      pkgs.corefonts
      pkgs.nerdfonts
      pkgs.font-awesome_5
    ];
    fontconfig.enable = true;
  };

  networking = {
    hostName = "metal";
    firewall = {
      enable = true;
      allowedUDPPorts = [
        5678 # Mikrotik NDP
        37008 # traffic sniffer on Mikrotik
      ];
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
  };
  users.users.pbor.extraGroups = [ "adbusers" "docker" "wireshark" ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    # Make sure keyboard interrupt doesn't abort suspend. ¯\_(ツ)_/¯ Linux is such a Linux
    powerDownCommands = ''
      sleep 0.1
    '';
  };

  services = {
    resolved.enable = true;
    journald.extraConfig = ''
      SystemMaxUse=100M
    '';
    dbus.packages = [ pkgs.gcr ];
    flatpak.enable = true;
    udev.extraRules = ''
      # Disable wakeup from suspend by mouse movement/click
      ACTION=="add", ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="60e6", ATTR{power/wakeup}="disabled"
    '';
  };

  xdg.portal.enable = true;

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "21.11";
}
