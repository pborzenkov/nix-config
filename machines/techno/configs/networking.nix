{
  config,
  machineSecrets,
  ...
}:
{
  networking = {
    hostName = "techno";
    domain = "lab.borzenkov.net";

    useDHCP = false;
    useNetworkd = true;

    nftables.enable = true;

    firewall = {
      enable = true;
      trustedInterfaces = [ "wg0" ];
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
          PrivateKeyFile = config.age.secrets.wireguard-key.path;
        };
        wireguardPeers = [
          {
            PublicKey = "/qcJiPDpknM7hvAwfrxUS5D8IGJ3RAiTVYlfdg8eZzk=";
            AllowedIPs = [
              "192.168.88.0/24"
              "192.168.111.0/24"
            ];
            Endpoint = "vpn.borzenkov.net:13231";
            PersistentKeepalive = 15;
          }
        ];
      };
    };
    networks = {
      "40-enp1s0" = {
        matchConfig.Name = "enp1s0";
        networkConfig.DHCP = "ipv4";
        address = [ "2a01:4f8:1c1c:53d2::" ];
        routes = [
          { Gateway = "fe80::1"; }
        ];
      };
      "50-wg" = {
        name = "wg0";
        DHCP = "no";
        addresses = [
          {
            Address = "192.168.111.8/24";
          }
        ];
        routes = [
          {
            Destination = "192.168.88.0/24";
            Scope = "link";
          }
        ];
        dns = [ "192.168.111.1" ];
        domains = [ "lab.borzenkov.net" ];
      };
    };
  };

  services.resolved.enable = true;

  age.secrets.wireguard-key = {
    file = machineSecrets + "/wireguard-key.age";
    mode = "0640";
    owner = "root";
    group = "systemd-network";
  };
}
