{
  config,
  lib,
  pkgs,
  isDesktop,
  sharedSecrets,
  ...
}:
let
  cfg = config.pbor.taskwarrior;
in
{
  options = {
    pbor.taskwarrior.enable = (lib.mkEnableOption "Enable taskwarrior") // {
      default = config.pbor.enable && isDesktop;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.taskwarrior-sync = {
      file = sharedSecrets + "/taskwarrior-sync-secret.age";
      mode = "0400";
      owner = config.users.users.pbor.name;
      group = config.users.users.pbor.group;
    };

    hm =
      {
        osConfig,
        config,
        ...
      }:
      {
        programs.taskwarrior = {
          enable = true;
          package = pkgs.taskwarrior3;
          colorTheme = "dark-gray-blue-256";
          dataLocation = "${config.xdg.dataHome}/task";
          config = {
            sync = {
              server = {
                origin = "https://taskwarrior.lab.borzenkov.net";
                client_id = "e064beb7-49bf-4214-beec-49dd794fed50";
              };
            };
          };
          extraConfig = ''
            include ${osConfig.age.secrets.taskwarrior-sync.path}
          '';
        };

        home = {
          packages = [
            pkgs.taskwarrior-tui
          ];
          shellAliases = {
            tasktui = "taskwarrior-tui";
          };
        };
      };
  };
}
