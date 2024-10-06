{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.pbor.basetools.fd;
in {
  options = {
    pbor.basetools.fd.enable = (lib.mkEnableOption "Enable fd") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.fd = {
        enable = true;
      };
    };
  };
}
