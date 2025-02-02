{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}: let
  cfg = config.pbor.wm.hyprland;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.wm.hyprland.enable = (lib.mkEnableOption "Enable Hyprland") // {default = config.pbor.wm.enable;};
    pbor.wm.hyprland.monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        An array that configures monitors.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    hm = {config, ...}: {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;

        plugins = [
          pkgs.hyprlandPlugins.hy3
        ];

        settings = {
          "$mod" = "Super";

          general = {
            layout = "hy3";
          };

          bind = [
            "$mod, Return, exec, uwsm app -- foot"
            "$mod, d, exec, uwsm app -- wofi -S run"
            "$mod+Shift, s, exec, uwsm app -- wofi-power-menu"
            "$mod+Shift, comma, exec, uwsm app -- wofi-sound-menu input"
            "$mod+Shift, period, exec, uwsm app -- wofi-sound-menu output"

            "$mod, h, hy3:movefocus, l"
            "$mod, j, hy3:movefocus, d"
            "$mod, k, hy3:movefocus, u"
            "$mod, l, hy3:movefocus, r"

            "$mod+Shift, h, hy3:movewindow, l, once"
            "$mod+Shift, j, hy3:movewindow, d, once"
            "$mod+Shift, k, hy3:movewindow, u, once"
            "$mod+Shift, l, hy3:movewindow, r, once"

            "$mod, 1, workspace, 01"
            "$mod, 2, workspace, 02"
            "$mod, 3, workspace, 03"
            "$mod, 4, workspace, 04"
            "$mod, 5, workspace, 05"
            "$mod, 6, workspace, 06"
            "$mod, 7, workspace, 07"
            "$mod, 8, workspace, 08"
            "$mod, 9, workspace, 09"
            "$mod, 0, workspace, 10"

            "$mod+Shift, 1, hy3:movetoworkspace, 01"
            "$mod+Shift, 2, hy3:movetoworkspace, 02"
            "$mod+Shift, 3, hy3:movetoworkspace, 03"
            "$mod+Shift, 4, hy3:movetoworkspace, 04"
            "$mod+Shift, 5, hy3:movetoworkspace, 05"
            "$mod+Shift, 6, hy3:movetoworkspace, 06"
            "$mod+Shift, 7, hy3:movetoworkspace, 07"
            "$mod+Shift, 8, hy3:movetoworkspace, 08"
            "$mod+Shift, 9, hy3:movetoworkspace, 09"
            "$mod+Shift, 0, hy3:movetoworkspace, 10"
          ];

          monitor = cfg.monitors;
        };
      };
      stylix.targets.hyprland.enable = true;
    };
  };
}
