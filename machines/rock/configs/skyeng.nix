{
  config,
  pkgs,
  machineSecrets,
  ...
}:
{
  systemd.services.tg-bot-skyeng =
    let
      cfg = pkgs.writeText "config.json" (
        builtins.toJSON {
          http_port = 8080;
          send_interval = 360;
          skyeng = {
            user = "maria@bagdasarova.com";
          };
          bot = {
            user = "mashahooyasha";
          };
          yaml_storage = {
            file_path = "/var/lib/skyeng-push-notificator/storage.yaml";
          };
        }
      );
    in
    {
      description = "Telegram bot for Skyeng word lists";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.nur.repos.pborzenkov.tg-bot-skyeng}/bin/cmd --config ${cfg}
        '';
        EnvironmentFile = [
          config.age.secrets.skyeng-push-notificator.path
        ];
        StateDirectory = "skyeng-push-notificator";
        Restart = "always";
        DynamicUser = true;
      };
    };

  age.secrets.skyeng-push-notificator.file =
    machineSecrets + "/skyeng-push-notificator-environment.age";
}
