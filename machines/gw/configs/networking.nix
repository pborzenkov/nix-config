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

    interfaces = {
      "enp1s0" = {
        useDHCP = true;
      };
    };
  };

  pbor.vpn = {
    enable = true;
    address = "192.168.111.2";
    keyfile = config.age.secrets.wireguard-key.path;
  };

  services.resolved.enable = true;

  age.secrets.wireguard-key = {
    file = machineSecrets + "/wireguard-key.age";
    mode = "0640";
    owner = "root";
    group = "systemd-network";
  };
}
