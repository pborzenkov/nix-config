{ config, lib, pkgs, modulesPath, nixos-hardware, sops-nix, nur, ... }:

{
  imports = [
    ./hardware-configuration.nix

    (modulesPath + "/profiles/headless.nix")

    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-pc-ssd

    ../../openssh.nix
  ];

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

    kernelPackages = pkgs.linuxPackages_5_14;
  };

  users = {
    users.pbor.extraGroups = [ "docker" ];
  };

  hardware.enableRedistributableFirmware = true;

  networking = {
    firewall.enable = true;
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

  virtualisation.oci-containers.backend = "docker";

  system.stateVersion = "21.05";

  # TMP
  networking.extraHosts = ''
    192.168.178.17 helios64.lan
    192.168.178.18 rock.lan
    192.168.178.74 transmission.lan
  '';
}
