{ config, lib, pkgs, ... }:
{
  services.nginx.streamConfig = ''
    server {
      listen 2456 udp;
      proxy_pass 100.115.192.117:2456;
    }

    server {
      listen 2457 udp;
      proxy_pass 100.115.192.117:2457;
    }
  '';

  networking.firewall.allowedUDPPorts = [ 2456 2457 ];
}
