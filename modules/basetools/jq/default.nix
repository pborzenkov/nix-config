{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.pbor.basetools.jq;
in {
  options = {
    pbor.basetools.jq.enable = (lib.mkEnableOption "Enable jq") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.jq = {
        enable = true;
      };
    };
  };
}
