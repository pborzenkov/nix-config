{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.taskwarrior;
in {
  options = {
    pbor.taskwarrior.enable = (lib.mkEnableOption "Enable taskwarrior") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
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
        include /run/secrets/taskwarrior-sync
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
}
