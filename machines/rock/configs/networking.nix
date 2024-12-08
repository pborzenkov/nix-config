{...}: {
  networking = {
    hostName = "rock";
    domain = "gw.lab.borzenkov.net";

    useDHCP = false;
    useNetworkd = true;

    nftables.enable = true;

    firewall = {
      enable = true;
    };
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
          IPv4Forwarding = "yes";
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

  services.resolved.enable = true;
}
