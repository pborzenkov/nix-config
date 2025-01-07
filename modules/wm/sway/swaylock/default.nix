{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.wm.sway.swaylock;
in {
  options = {
    pbor.wm.sway.swaylock.enable = (lib.mkEnableOption "Enable swaylock") // {default = config.pbor.wm.sway.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm = {
      programs.swaylock = {
        enable = true;
        settings = {
          font = config.stylix.fonts.monospace.name;
          indicator-idle-visible = true;
          indicator-radius = 130;
          indicator-thickness = 15;

          ignore-empty-password = true;
        };
      };
      stylix.targets.swaylock = {
        enable = true;
        useImage = false;
      };
    };
  };
}
