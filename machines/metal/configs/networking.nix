{...}: {
  networking = {
    hostName = "metal";
    domain = "lab.borzenkov.net";

    useDHCP = false;
    useNetworkd = true;

    nftables.enable = true;

    interfaces = {
      "enp8s0" = {
        useDHCP = true;
        wakeOnLan.enable = true;
      };
    };
  };
  services.resolved.enable = true;
  systemd.network.networks."40-enp8s0".dhcpV4Config.UseDomains = true;
}
