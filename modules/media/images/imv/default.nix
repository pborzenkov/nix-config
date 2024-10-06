{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.pbor.media.images.imv;
in {
  options = {
    pbor.media.images.imv.enable = (lib.mkEnableOption "Enable imv") // {default = config.pbor.media.images.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.imv = {
        enable = true;
        settings = {
          binds = {
            "<Shift+greater>" = "next 1";
            "<Shift+less>" = "prev 1";
          };
        };
      };
    };
  };
}
