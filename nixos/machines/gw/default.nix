# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    (modulesPath + "/profiles/headless.nix")

    inputs.nixos-hardware.nixosModules.common-pc-ssd

    inputs.sops-nix.nixosModules.sops

    ../../openssh.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = ["/dev/vda"];
    };

    kernelPackages = pkgs.linuxPackages_6_2;
  };

  networking = {
    hostName = "gw";
    useDHCP = false;
    dhcpcd.enable = false;
    useNetworkd = true;

    firewall = {
      enable = true;
      trustedInterfaces = ["wg0"];
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      "50-wg" = {
        netdevConfig = {
          Kind = "wireguard";
          MTUBytes = "1420";
          Name = "wg0";
        };
        wireguardConfig = {
          ListenPort = 13231;
          PrivateKeyFile = config.sops.secrets.wireguard-private-key.path;
        };
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = "/qcJiPDpknM7hvAwfrxUS5D8IGJ3RAiTVYlfdg8eZzk=";
              AllowedIPs = ["192.168.88.0/24" "192.168.111.0/24"];
              Endpoint = "vpn.borzenkov.net:13231";
              PersistentKeepalive = 15;
            };
          }
        ];
      };
    };
    networks = {
      "40-wired" = {
        name = "enp1s0";
        DHCP = "yes";
        networkConfig = {
          LinkLocalAddressing = "no";
        };
      };
      "50-wg" = {
        name = "wg0";
        DHCP = "no";
        addresses = [
          {
            addressConfig = {
              Address = "192.168.111.2/24";
            };
          }
        ];
        routes = [
          {
            routeConfig = {
              Destination = "192.168.88.0/24";
              Scope = "link";
            };
          }
        ];
        dns = ["192.168.111.1"];
        domains = ["lab.borzenkov.net"];
      };
    };
  };
  sops.secrets.wireguard-private-key = {
    mode = "0640";
    owner = "root";
    group = "systemd-network";
  };

  services = {
    resolved.enable = true;
    openssh.openFirewall = true;
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "20.09";
}
