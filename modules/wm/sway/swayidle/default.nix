{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.wm.sway.swayidle;
in {
  options = {
    pbor.wm.sway.swayidle.enable = (lib.mkEnableOption "Enable swayidle") // {default = config.pbor.wm.sway.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      services.swayidle = {
        enable = true;
        systemdTarget = "sway-session.target";
        timeouts = [
          {
            timeout = 300;
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            timeout = 600;
            command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
            resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
          }
          {
            timeout = 900;
            command = "${pkgs.systemd}/bin/systemctl suspend";
            resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
          }
        ];
        events = [
          {
            event = "before-sleep";
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            event = "lock";
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
        ];
      };
    };
  };
}
