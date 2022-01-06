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

    kernelPackages = pkgs.linuxPackages_5_15;
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
    ];

    binfmt.registrations = {
      DOSWin = {
        interpreter = "${pkgs.wine}/bin/wine";
        magicOrExtension = "MZ";
        recognitionType = "magic";
      };
    };
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
    firewall = {
      enable = true;
      allowedUDPPorts = [ 5678 ];
    };
    interfaces.enp8s0.useDHCP = true;
    hostName = "metal";
    dhcpcd = {
      wait = "ipv4";
      extraConfig = ''
        noarp
        clientid
      '';
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
  };

  services = {
    journald.extraConfig = ''
      SystemMaxUse=100M
    '';
    dbus.packages = [ pkgs.gcr ];
  };

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "21.11";
}
