{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.niri.polkit;
in
{
  options = {
    pbor.wm.niri.polkit.enable = (lib.mkEnableOption "Enable polkit") // {
      default = config.pbor.wm.niri.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        Unit = {
          After = [ "graphical-session.target" ];
        };

        Service = {
          Type = "exec";
          ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "niri" ""'';
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          Slice = "background-graphical.slice";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
