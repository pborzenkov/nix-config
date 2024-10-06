{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.basetools.restic;
in {
  options = {
    pbor.basetools.restic.enable = (lib.mkEnableOption "Enable restic") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.packages = [
        pkgs.restic
      ];

      home.sessionVariables = {
        RESTIC_REPOSITORY = "sftp:zh1012@zh1012.rsync.net:restic";
        RESTIC_PASSWORD_COMMAND = "pass misc/restic@resync.net";
      };
    };
  };
}
