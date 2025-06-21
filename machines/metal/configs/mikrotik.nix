{ ... }:
{
  networking = {
    firewall = {
      allowedUDPPorts = [
        5678 # Mikrotik NDP
        37008 # traffic sniffer on Mikrotik
      ];
      extraInputRules = ''
        udp sport 20561 accept # Mikrotik MAC telnet
      '';
    };
  };
}
