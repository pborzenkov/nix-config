{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.niri.swayidle;
in
{
  options = {
    pbor.wm.niri.swayidle.enable = (lib.mkEnableOption "Enable swayidle") // {
      default = config.pbor.wm.niri.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
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
          useWallpaper = false;
        };

        services.swayidle = {
          enable = true;
          systemdTarget = "graphical-session.target";
          timeouts = [
            {
              timeout = 300;
              command = "${pkgs.swaylock}/bin/swaylock -f";
            }
            {
              timeout = 600;
              command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
              resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
            }
            {
              timeout = 900;
              command = "${pkgs.systemd}/bin/systemctl suspend";
            }
          ];
          events = [
            {
              event = "before-sleep";
              command = "${pkgs.swaylock}/bin/swaylock -f";
            }
            {
              event = "after-resume";
              command = "${pkgs.niri}/bin/niri msg action power-on-monitors";
            }
            {
              event = "lock";
              command = "${pkgs.swaylock}/bin/swaylock -f";
            }
          ];
        };
        systemd.user.services.swayidle = {
          Unit = lib.mkForce {
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "niri" ""'';
            Slice = "background-graphical.slice";
          };
        };
      };
  };
}
