{
  config,
  lib,
  pkgs,
  machineSecrets,
  ...
}:
{
  systemd.services.v2ray = {
    restartTriggers = [ config.age.secrets.v2ray-config.path ];

    serviceConfig = {
      LoadCredential = "config.json:${config.age.secrets.v2ray-config.path}";
      ExecStart = lib.mkForce "${lib.getExe pkgs.v2ray} run -config %d/config.json";
    };

    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 443 ];

  age.secrets.v2ray-config.file = machineSecrets + "/v2ray-config.age";
}
