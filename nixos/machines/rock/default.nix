{
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    (modulesPath + "/profiles/headless.nix")

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ./anki.nix
    ./arr.nix
    ./backup.nix
    ./books.nix
    ./dashboard.nix
    ./grafana.nix
    ./invidious.nix
    ./jellyfin.nix
    ./koreader.nix
    ./libvirt.nix
    ./miniflux.nix
    ./mpd.nix
    ./photoprism.nix
    ./pim.nix
    ./postgresql.nix
    ./prometheus.nix
    ./redis.nix
    ./torrent.nix
    ./shiori.nix
    ./skyeng.nix
    ./sound.nix
    ./storage.nix
    ./syncthing.nix
    ./taskwarrior.nix
    ./terraform.nix
    ./valheim.nix
    ./vlmcsd.nix
    ./vpn.nix
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

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "nct6775"
    ];

    supportedFilesystems = ["ntfs"];
  };

  users.users.pbor.extraGroups = ["libvirtd"];

  hardware.enableRedistributableFirmware = true;

  networking = {
    firewall.enable = true;
    hostName = "rock";
    useDHCP = false;
    dhcpcd.enable = false;
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;
    netdevs."40-mv-host" = {
      enable = true;
      netdevConfig = {
        Name = "mv-host";
        Kind = "macvlan";
        MACAddress = "56:bc:92:cb:57:b6";
      };
      macvlanConfig = {
        Mode = "bridge";
      };
    };
    networks = {
      "40-mv-host" = {
        enable = true;
        name = "mv-host";
        DHCP = "ipv4";
        networkConfig = {
          IPForward = "yes";
          LinkLocalAddressing = "no";
        };
      };
      "40-enp2s0" = {
        enable = true;
        name = "enp2s0";
        macvlan = ["mv-host"];
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
    };
    wait-online.anyInterface = true;
  };
  services = {
    avahi.enable = true;
    resolved.enable = true;
    openssh.openFirewall = true;
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

  system.stateVersion = "23.05";
}
