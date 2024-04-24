{
  config,
  pkgs,
  ...
}: {
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = true;
      ExecStart = "${pkgs.writers.writeDash "netns-up" ''
        ${pkgs.iproute}/bin/ip netns add $1
        ${pkgs.utillinux}/bin/umount /var/run/netns/$1
        ${pkgs.utillinux}/bin/mount --bind /proc/self/ns/net /var/run/netns/$1
      ''} %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
      PrivateMounts = false;
    };
  };

  environment.etc.amsterdam-resolv = {
    enable = true;
    text = ''
      nameserver 10.2.0.1
    '';
    target = "netns/amsterdam/resolv.conf";
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      amsterdam = {
        interfaceNamespace = "amsterdam";
        privateKeyFile = config.sops.secrets.protonvpn-amsterdam.path;
        ips = ["10.2.0.2/32"];
        peers = [
          {
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "185.107.44.110:51820";
            publicKey = "YgGdHIXeCQgBc4nXKJ4vct8S0fPqBpTgk4I8gh3uMEg=";
          }
        ];
      };
    };
  };
  systemd.services.wireguard-amsterdam = {
    bindsTo = ["netns@amsterdam.service"];
    serviceConfig.StateDirectory = "wireguard-amsterdam";
  };

  sops.secrets = {
    protonvpn-amsterdam = {};
  };
}
