{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.wm.hyprland.hypridle;
in {
  options = {
    pbor.wm.hyprland.hypridle.enable = (lib.mkEnableOption "Enable hypridle") // {default = config.pbor.wm.hyprland.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm = {config, ...}: {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dmps on";
          };

          listener = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 600;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 900;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
      systemd.user.services.hypridle = lib.mkForce {
        Unit = {
          After = ["graphical-session.target"];
        };

        Service = {
          Type = "exec";
          ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "Hyprland" ""'';
          ExecStart = "${lib.getExe config.services.hypridle.package}";
          Restart = "on-failure";
          Slice = "background-graphical.slice";
        };

        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
