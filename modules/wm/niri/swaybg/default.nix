{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.niri.swaybg;
in
{
  options = {
    pbor.wm.niri.swaybg.enable = (lib.mkEnableOption "Enable swaybg") // {
      default = config.pbor.wm.niri.enable;
    };
    pbor.wm.niri.swaybg.args = (lib.mkEnableOption "Swaybg arguments") // {
      type = lib.types.listOf lib.types.str;
      default = [
        "-m"
        config.stylix.imageScalingMode
        "-i"
        config.stylix.image
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      systemd.user.services.swaybg = {
        Unit = {
          After = [ "graphical-session.target" ];
        };

        Service = {
          Type = "exec";
          ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "niri" ""'';
          ExecStart = ''${lib.getExe pkgs.swaybg} ${builtins.concatStringsSep " " cfg.args}'';
          Restart = "on-failure";
          Slice = "background-graphical.slice";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
