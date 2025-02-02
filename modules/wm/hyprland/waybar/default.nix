{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.wm.hyprland.waybar;
in {
  options = {
    pbor.wm.hyprland.waybar.enable = (lib.mkEnableOption "Enable waybar") // {default = config.pbor.wm.hyprland.enable;};
    pbor.wm.hyprland.waybar.pulseaudio-icons = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
      default = null;
      description = ''Sound device mappings.'';
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {config, ...}: {
      programs.waybar = {
        enable = true;
        settings = {
          default = {
            layer = "top";
            position = "top";
            height = 24;

            # modules-left = ["hyprland/workspaces"];
            modules-center = ["hyprland/window"];
            modules-right = ["pulseaudio" "hyprland/language" "clock"];

            pulseaudio = {
              format = "{icon} {volume}%";
              format-icons = cfg.pulseaudio-icons;
            };
          };
        };
        style = ''
          * {
            font-family: "${config.stylix.fonts.monospace.name}", "Font Awesome 6 Free";
          }
        '';
      };
      stylix.targets.waybar.enable = true;
      systemd.user.services.waybar = {
        Unit = {
          After = ["graphical-session.target"];
        };

        Service = {
          Type = "exec";
          ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "Hyprland" ""'';
          ExecStart = "${lib.getExe config.programs.waybar.package}";
          Restart = "on-failure";
          Slice = "background-graphical.slice";
        };

        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
