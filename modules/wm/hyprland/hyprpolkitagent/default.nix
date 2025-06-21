{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.hyprland.hyprpolkitagent;
in
{
  options = {
    pbor.wm.hyprland.hyprpolkitagent.enable = (lib.mkEnableOption "Enable hyprpolkitagent") // {
      default = config.pbor.wm.hyprland.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
        systemd.user.services.hyprpolkitagent = {
          Unit = {
            After = [ "graphical-session.target" ];
          };

          Service = {
            Type = "exec";
            ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "Hyprland" ""'';
            ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
            Restart = "on-failure";
            Slice = "background-graphical.slice";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
