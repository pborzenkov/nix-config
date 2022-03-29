{ config, pkgs, ... }:

{
  # Reboot this fucking Ziggo modem at least once a day. Otherwise it turns to shit and can barely do 10Mbit/s.
  systemd.services.reboot-ziggo-modem = {
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "reboot-ziggo-modem" ''
        SESSION=$(mktemp -u)
        ${pkgs.xh}/bin/xh --session $SESSION -f POST http://192.168.178.1/htdocs/login_check.php loginPassword=$ZIGGO_ADMIN_PASSWORD
        ${pkgs.xh}/bin/xh --session $SESSION -f POST http://192.168.178.1/htdocs/ubee_php_lib/ubee_php_post.php mgt_default_reset=0x01
      '';
      User = "root";
      EnvironmentFile = [
        config.sops.secrets.ziggo-modem.path
      ];
    };
  };

  sops.secrets.ziggo-modem = { };

  systemd.timers.reboot-ziggo-modem = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "01:45";
    };
  };
}
