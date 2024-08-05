{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.wm.sway;
in {
  imports = [
    ./swayidle
    ./swaylock
  ];

  options = {
    pbor.wm.sway.enable = (lib.mkEnableOption "Enable Sway") // {default = config.pbor.wm.enable;};
  };

  config =
    lib.mkIf cfg.enable {
    };
}
