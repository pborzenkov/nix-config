{ config, lib, pkgs, modulesPath, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix

    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-pc-ssd

    ../../openssh.nix
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

    kernelPackages = pkgs.linuxPackages_5_14;
  };

  hardware.enableRedistributableFirmware = true;

  networking = {
    firewall.enable = true;
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

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=100M
  '';

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "21.11";

  # TMP
  networking.extraHosts = ''
    192.168.178.17 helios64.lan
    192.168.178.18 rock.lan
    192.168.178.74 transmission.lan
  '';
}
