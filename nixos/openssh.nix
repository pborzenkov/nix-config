{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    logLevel = "INFO";
    passwordAuthentication = false;
    permitRootLogin = "no";

    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };
}
