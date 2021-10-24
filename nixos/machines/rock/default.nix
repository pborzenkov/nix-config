{ config, lib, pkgs, modulesPath, nixos-hardware, sops-nix, nur, ... }:

{
  imports = [
    ./hardware-configuration.nix

    (modulesPath + "/profiles/headless.nix")

    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-pc-ssd

    sops-nix.nixosModules.sops

    ../../docker.nix
    ../../openssh.nix

    ./backup.nix
    ./gonic.nix
    ./grafana.nix
    ./jellyfin.nix
    ./helios64.nix
    ./miniflux.nix
    ./photoprism.nix
    ./plex.nix
    ./postgresql.nix
    ./skyeng-push-notificator.nix
    ./syncthing.nix
    ./transmission.nix
    ./valheim.nix
    ./vlmcsd.nix
    ./webapps.nix
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
    kernelModules = [
      "nct6775"
    ];

    supportedFilesystems = [ "ntfs" ];
  };

  fileSystems."/storage" = {
    device = "192.168.178.17:/storage";
    fsType = "nfs";
  };

  users = {
    users.pbor.extraGroups = [ "docker" "nas" ];

    groups.nas.gid = 998;
  };

  hardware.enableRedistributableFirmware = true;

  networking = {
    firewall.enable = true;
    hostName = "rock";
    macvlans.mv-host-enp2s0 = {
      interface = "enp2s0";
      mode = "bridge";
    };
    interfaces = {
      enp2s0.useDHCP = false;
      mv-host-enp2s0 = {
        macAddress = "56:bc:92:cb:57:b6";
        useDHCP = true;
      };
    };
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

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  services.journald.extraConfig = ''
    SystemMaxUse=100M
  '';

  time.timeZone = "Europe/Amsterdam";

  virtualisation.oci-containers.backend = "docker";

  system.stateVersion = "20.09";
}
