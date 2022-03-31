{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [ "tf_infra" ];
    authentication = ''
      host  all all 192.168.88.0/24 md5
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
