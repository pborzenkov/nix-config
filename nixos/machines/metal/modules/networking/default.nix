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

  networking = {
    firewall = {
      allowedTCPPorts = [
        9090 # Calibre sync server
        27036 # Steam
      ];
      allowedUDPPorts = [
        5678 # Mikrotik NDP
        37008 # traffic sniffer on Mikrotik
      ];
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27035;
        } # Steam
      ];
      extraInputRules = ''
        udp sport 20561 accept # Mikrotik MAC telnet
      '';
    };
  };
}
