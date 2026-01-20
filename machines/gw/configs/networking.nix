{
  config,
  machineSecrets,
  ...
}:
{
  networking = {
    hostName = "gw";
    domain = "lab.borzenkov.net";

    useDHCP = false;
    useNetworkd = true;

    nftables.enable = true;

    firewall = {
      enable = true;
      trustedInterfaces = [ "wg0" ];
    };
  };

  pbor.vpn = {
    enable = true;
    address = "192.168.111.2";
    keyfile = config.age.secrets.wireguard-key.path;
  };

  systemd.network = {
    networks = {
      "40-enp1s0" = {
        matchConfig.Name = "enp1s0";
        networkConfig.DHCP = "ipv4";
        address = [ "2a01:4f8:1c1f:978b::1" ];
        routes = [
          { Gateway = "fe80::1"; }
        ];
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
