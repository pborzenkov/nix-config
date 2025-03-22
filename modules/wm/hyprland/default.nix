{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}: let
  cfg = config.pbor.wm.hyprland;

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    text = builtins.readFile ./scripts/screenshot.sh;
    runtimeInputs = [pkgs.hyprland pkgs.jq pkgs.grim pkgs.slurp pkgs.wl-clipboard];
  };
  scratch-app = pkgs.writeShellApplication {
    name = "scratch-app";
    text = builtins.readFile ./scripts/scratch-app.sh;
    runtimeInputs = [pkgs.hyprland pkgs.jq];
  };
  per-app-remapper = pkgs.writeShellApplication {
    name = "per-app-remapper";
    text = builtins.readFile ./scripts/per-app-remapper.sh;
    runtimeInputs = [pkgs.hyprland pkgs.socat];
  };
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
    pbor.wm.hyprland.workspace-rules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        An array of workspace rules.
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
            gaps_in = 0;
            gaps_out = 0;
          };

          input = {
            kb_layout = "us,ru";
            kb_options = "caps:escape,compose:paus";
          };

          decoration = {
            blur.enabled = false;
            shadow.enabled = false;
          };
          animations.enabled = false;

          plugin.hy3 = {
            tabs = {
              text_font = config.stylix.fonts.monospace.name;
              padding = 0;
              blur = false;
            };
          };

          bind = [
            "$mod, space, exec, uwsm app -- hyprctl switchxkblayout main next"
            "$mod, Return, exec, uwsm app -- foot"
            "$mod+Shift, Return, exec, uwsm app -- ${scratch-app}/bin/scratch-app -c term"
            "$mod, d, exec, uwsm app -- wofi -S run"
            "$mod+Shift, s, exec, uwsm app -- wofi-power-menu"
            "$mod+Shift, period, exec, uwsm app -- ${scratch-app}/bin/scratch-app -c mixer -- ncpamixer -t o"
            "$mod+Shift, m, exec, uwsm app -- ${scratch-app}/bin/scratch-app -c mail -- aerc"

            "$mod, q, hy3:killactive"
            "$mod+Shift, q, exec, uwsm app -- hyprctl kill"
            "$mod+Shift, c, exec, uwsm app -- hyprpicker -a -n"
            "$mod, bracketleft, hy3:changefocus, raise"
            "$mod, bracketright, hy3:changefocus, lower"
            "$mod, grave, hy3:togglefocuslayer"
            "$mod, f, fullscreen, 1"

            "$mod, h, hy3:movefocus, l, visible"
            "$mod, j, hy3:movefocus, d, visible"
            "$mod, k, hy3:movefocus, u, visible"
            "$mod, l, hy3:movefocus, r, visible"

            "$mod+Shift, h, hy3:movewindow, l, once"
            "$mod+Shift, j, hy3:movewindow, d, once"
            "$mod+Shift, k, hy3:movewindow, u, once"
            "$mod+Shift, l, hy3:movewindow, r, once"

            "$mod+Ctrl, h, movecurrentworkspacetomonitor, l"
            "$mod+Ctrl, l, movecurrentworkspacetomonitor, r"

            "$mod, t, hy3:makegroup, tab, ephemeral"
            "$mod+Shift, t, hy3:changegroup, toggletab"
            "$mod, a, hy3:makegroup, v, ephemeral"
            "$mod+Shift, a, hy3:changegroup, opposite"

            "alt, 1, hy3:focustab, index, 01"
            "alt, 2, hy3:focustab, index, 02"
            "alt, 3, hy3:focustab, index, 03"
            "alt, 4, hy3:focustab, index, 04"
            "alt, 5, hy3:focustab, index, 05"
            "alt, 6, hy3:focustab, index, 06"
            "alt, 7, hy3:focustab, index, 07"
            "alt, 8, hy3:focustab, index, 08"
            "alt, 9, hy3:focustab, index, 09"
            "alt, 0, hy3:focustab, index, 10"

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

            ", XF86AudioRaiseVolume, exec, uwsm app -- pactl set-sink-volume @DEFAULT_SINK@ +5%"
            ", XF86AudioLowerVolume, exec, uwsm app -- pactl set-sink-volume @DEFAULT_SINK@ -5%"
            ", XF86AudioMute, exec, uwsm app -- pactl set-sink-mute @DEFAULT_SINK@ toggle"
            ", XF86AudioPrev, exec, uwsm app -- playerctl -p mpd previous"
            ", XF86AudioNext, exec, uwsm app -- playerctl -p mpd next"
            ", XF86AudioPlay, exec, uwsm app -- playerctl -p mpd play-pause"
            "$mod+Shift, n, exec, uwsm app -- dunstctl set-paused toggle"

            ", Print, exec, uwsm app -- ${screenshot}/bin/screenshot select-copy"
            "Shift, Print, exec, uwsm app -- ${screenshot}/bin/screenshot select-file"
            "Ctrl, Print, exec, uwsm app -- ${screenshot}/bin/screenshot fullscreen-copy"
            "Ctrl+Shift, Print, exec, uwsm app -- ${screenshot}/bin/screenshot fullscreen-file"
          ];

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

          windowrulev2 = [
            "float, class:scratch-term"
            "size 75% 75%, class:scratch-term"
            "float, class:scratch-mixer"
            "size 60% 60%, class:scratch-mixer"
            "float, class:scratch-mail"
            "size 75% 90%, class:scratch-mail"

            "bordercolor rgb(${config.lib.stylix.colors.base08}), fullscreen:1"

            "float, class:steam"
          ];

          monitor = cfg.monitors;
          workspace = cfg.workspace-rules;
        };

        extraConfig = ''
          bind = $mod, r, submap, resize

          submap = resize
          binde = , l, resizeactive, 10 0
          binde = , h, resizeactive, -10 0
          binde = , j, resizeactive, 0 10
          binde = , k, resizeactive, 0 -10
          bind = $mod, r, submap, reset
          bind = , escape, submap, reset
          submap = reset
        '';
      };
      stylix.targets.hyprland.enable = true;

      home.packages = with pkgs; [
        hyprpicker
      ];

      systemd.user.services.per-app-remapper = lib.mkForce {
        Unit = {
          After = ["graphical-session.target"];
        };

        Service = {
          Type = "exec";
          ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "Hyprland" ""'';
          ExecStart = "${per-app-remapper}/bin/per-app-remapper";
          Restart = "on-failure";
          Slice = "background-graphical.slice";
        };

        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
