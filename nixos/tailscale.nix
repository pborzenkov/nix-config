{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.tailscale
  ];

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
