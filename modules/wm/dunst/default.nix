{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.dunst;
in
{
  options = {
    pbor.wm.dunst.enable = (lib.mkEnableOption "Enable dunst") // {
      default = config.pbor.wm.enable;
    };
    pbor.wm.dunst.monitor = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = ''
        A monitor to show notifications on.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      services.dunst = {
        enable = true;
        settings = {
          global = {
            monitor = cfg.monitor;
            follow = "mouse";
          };
        };
      };
      stylix.targets.dunst.enable = true;

      home.packages = with pkgs; [
        libnotify
      ];
    };
  };
}
