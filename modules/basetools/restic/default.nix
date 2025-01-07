{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.basetools.restic;
in {
  options = {
    pbor.basetools.restic.enable = (lib.mkEnableOption "Enable restic") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm.home = {
      packages = [
        pkgs.restic
      ];

      sessionVariables = {
        RESTIC_REPOSITORY = "sftp:zh1012@zh1012.rsync.net:restic";
        RESTIC_PASSWORD_COMMAND = "rbw get rsync.net/restic";
      };
    };
  };
}
