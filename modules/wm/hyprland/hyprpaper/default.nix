{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.hyprland.hyprpaper;
in
{
  options = {
    pbor.wm.hyprland.hyprpaper.enable = (lib.mkEnableOption "Enable hyprpaper") // {
      default = config.pbor.wm.hyprland.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
        services.hyprpaper = {
          enable = true;
        };
        systemd.user.services.hyprpaper = lib.mkForce {
          Unit = {
            After = [ "graphical-session.target" ];
          };

          Service = {
            Type = "exec";
            ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "Hyprland" ""'';
            ExecStart = "${lib.getExe config.services.hyprpaper.package}";
            Restart = "on-failure";
            Slice = "background-graphical.slice";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };
        stylix.targets.hyprpaper.enable = true;
      };
  };
}
