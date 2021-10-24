{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.docker
    pkgs.docker-compose
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune.enable = true;
  };
}
