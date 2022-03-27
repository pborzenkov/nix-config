{ config, lib, pkgs, modulesPath, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix

    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-pc-ssd

    ../../openssh.nix

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

    kernelPackages = pkgs.linuxPackages_5_16;
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
    device = "helios64.lan:/storage";
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
      allowedUDPPorts = [ 5678 ];
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
    };
  };

  programs = {
    adb.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
  users.users.pbor.extraGroups = [ "adbusers" "wireshark" ];

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
