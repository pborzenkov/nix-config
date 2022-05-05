# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      (modulesPath + "/profiles/headless.nix")

      inputs.nixos-hardware.nixosModules.common-pc-ssd

      ../../openssh.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/vda" ];
    };

    kernelPackages = pkgs.linuxPackages_5_17;
    kernel.sysctl = {
      "net.ipv4.ip_forward" = true;
    };
  };

  networking = {
    hostName = "gw";
    useDHCP = false;
    dhcpcd.enable = false;
    useNetworkd = true;

    firewall =
      let
        rock = "100.115.192.117";
        iface = "enp1s0";
        nginxCmd = "-i ${iface} -p tcp --match multiport --destination-ports 80,443 -j DNAT --to-destination ${rock}";
      in
      {
        enable = true;
        # Nginx
        allowedTCPPorts = [ 80 443 ];

        extraCommands = ''
          iptables -t nat -I POSTROUTING -o tailscale0 -j MASQUERADE
          iptables -t nat -I PREROUTING ${nginxCmd}
        '';
        extraStopCommands = ''
          iptables -t nat -D PREROUTING ${nginxCmd} || true
          iptables -t nat -D POSTROUTING -o tailscale0 -j MASQUERADE || true
        '';
      };
  };

  systemd.network = {
    enable = true;
    networks."40-wired" = {
      name = "enp1s0";
      DHCP = "yes";
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
  };
  services.resolved.enable = true;

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "20.09";
}
