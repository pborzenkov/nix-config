{ config, pkgs, ... }:

let
  dnsConfig = pkgs.writeText "dnsConfig" ''
    $ORIGIN lab.borzenkov.net.
    @ 3600 IN SOA sns.dns.icann.org. noc.dns.icann.org. (
                                     2017042745 ; serial
                                     7200       ; refresh (2 hours)
                                     3600       ; retry (1 hour)
                                     1209600    ; expire (2 weeks)
                                     3600       ; minimum (1 hour)
                                     )

    3600 IN NS a.iana-servers.net.
    3600 IN NS b.iana-servers.net.

    rock           IN A     100.115.192.117
    metal          IN A     100.66.227.121
    jazz           IN A     100.119.81.97
    xperia-5-iii   IN A     100.90.11.34
    gw             IN A     100.103.2.96
    helios64       IN A     100.120.35.41
    booking-laptop IN A     100.65.242.53

    auth           IN CNAME rock
    dashboard      IN CNAME rock
    grafana        IN CNAME rock
    jellyfin       IN CNAME rock
    music          IN CNAME rock
    plex           IN CNAME rock
    prometheus     IN CNAME rock
    rss            IN CNAME rock
    transmission   IN CNAME rock
  '';
in
{
  services.coredns = {
    enable = true;
    config = ''
      lab.borzenkov.net {
        bind tailscale0
        file ${dnsConfig}
        prometheus 0.0.0.0:9153
        errors
        log
      }
    '';
  };

  systemd.services.coredns = {
    after = [
      "systemd-networkd.socket"
      "tailscaled.service"
    ];
    requires = [ "tailscaled.service" "systemd-networkd.socket" ];
    preStart = ''
      ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online --interface tailscale0
      sleep 1
    '';
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "coredns";
      static_configs = [
        {
          targets = [
            "rock.lan:9153"
          ];
        }
      ];
    }
  ];
}
