{ config, lib, pkgs, ... }:

{
  systemd.services.skyeng-push-notificator =
    let
      bot = pkgs.buildGoModule rec {
        pname = "skyeng-push-notificator";
        version = "2021-04-08-645c17d";

        src = pkgs.fetchFromGitHub {
          owner = "pachmu";
          repo = "skyeng-push-notificator";
          rev = "645c17d2cfc979adca3673ed07a26a6b9631690d";
          sha256 = "0684qxvc3izi60ly5rbxasl24cfxpx3lqx8p7bwwly95n8mc960c";
        };

        vendorSha256 = "1893j1v6qvflmx3qlbn8kikwypphr612r9p5f1y1d27x4m85by8f";

        subPackages = [ "cmd" ];

        meta = with lib; {
          homepage = "https://github.com/pachmu/skyeng-push-notificator";
          description = "Telegram bot for Skyeng word lists.";
          license = licenses.mit;
        };
      };

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
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = ''
            ${bot}/bin/cmd --config ${cfg}
          '';
          EnvironmentFile = [
            config.sops.secrets.skyeng-push-notificator.path
          ];
          StateDirectory = "skyeng-push-notificator";
          Restart = "always";
          DynamicUser = true;
        };
      };

  sops.secrets.skyeng-push-notificator = {};
}
