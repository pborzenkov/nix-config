# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, nixos-hardware, sops-nix, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      (modulesPath + "/profiles/headless.nix")

      nixos-hardware.nixosModules.common-pc-ssd

      sops-nix.nixosModules.sops

      ./valheim.nix
      ./webapps.nix
    ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/vda" ];
  };

  networking = {
    firewall.enable = true;
    hostName = "gw";

    interfaces.enp1s0.useDHCP = true;
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "20.09";
}
