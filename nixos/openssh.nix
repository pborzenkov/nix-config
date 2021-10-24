{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    logLevel = "INFO";
    openFirewall = true;
    passwordAuthentication = false;
    permitRootLogin = "no";

    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };
}
