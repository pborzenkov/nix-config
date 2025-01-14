{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.wm.hyprland.hyprlock;
in {
  options = {
    pbor.wm.hyprland.hyprlock.enable = (lib.mkEnableOption "Enable hyprlock") // {default = config.pbor.wm.hyprland.enable;};
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.hyprlock = {};

    hm = {
      programs.hyprlock = {
        enable = true;
        settings = {
          animations.enabled = false;
          input-field = {
            fade_on_empty = false;
          };
          background = {
            blur_passes = 2;
          };
        };
      };
      stylix.targets.hyprlock.enable = true;
    };
  };
}
