{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/macapps
  ];
  macapps.packages = [
    pkgs.alacritty
    pkgs.slack
  ];

  launchd.agents = {
    syncthing = {
      environment = {
        HOME = "/Users/pborzenkov";
        STNORESTART = "1";
      };
      serviceConfig = {
        Program = "${pkgs.syncthing}/bin/syncthing";
        KeepAlive = true;
        LowPriorityIO = true;
        ProcessType = "Background";
        StandardOutPath = "/Users/pborzenkov/Library/Logs/syncthing.log";
        StandardErrorPath = "/Users/pborzenkov/Library/Logs/syncthing.err.log";
      };
    };
  };
}
