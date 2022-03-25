{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../openssh.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_5_16;
  };

  networking = {
    hostName = "vm";
    firewall.enable = false;
    useDHCP = false;
    dhcpcd.enable = false;
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;
    networks."40-wired" = {
      name = "enp0s10";
      DHCP = "ipv4";
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
  };

  services = {
    resolved.enable = true;
    journald.extraConfig = ''
      SystemMaxUse=100M
    '';
  };

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "22.05";
}
