{
  config,
  lib,
  pkgs,
  machineSecrets,
  ...
}:
{
  systemd.services.xray = {
    restartTriggers = [ config.age.secrets.v2ray-config.path ];

    serviceConfig = {
      LoadCredential = "config.json:${config.age.secrets.v2ray-config.path}";
      ExecStart = lib.mkForce "${lib.getExe pkgs.xray} run -config %d/config.json";
    };

    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 443 ];

  services.prometheus.exporters = {
    v2ray = {
      enable = true;
      listenAddress = "192.168.111.8";
    };
  };

  age.secrets.v2ray-config.file = machineSecrets + "/v2ray-config.age";
}
