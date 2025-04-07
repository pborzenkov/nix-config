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
  settings = pkgs.writeShellApplication {
    name = "settings";
    text = builtins.readFile ./scripts/settings.sh;
    runtimeInputs = [pkgs.wofi pkgs.foot];
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

  scratch-term-zellij = let
    config = pkgs.writeTextFile {
      name = "scratch-term-zellij-config";
      text = ''
        on_force_close "detach"
        simplified_ui true
        pane_frames false
        default_shell "fish"
        theme "default"
        default_mode "locked"
        mouse_mode false
        copy_command "wl-copy"
        scrollback_editor "hx"
        session_serialization false
        show_startup_tips false
        show_release_notes false

        keybinds clear-defaults=true {
          locked {
            bind "Super Enter" { "NewTab"; }

            bind "Alt 1" { GoToTab 1; }
            bind "Alt 2" { GoToTab 2; }
            bind "Alt 3" { GoToTab 3; }
            bind "Alt 4" { GoToTab 4; }
            bind "Alt 5" { GoToTab 5; }
            bind "Alt 6" { GoToTab 6; }
            bind "Alt 7" { GoToTab 7; }
            bind "Alt 8" { GoToTab 8; }
            bind "Alt 9" { GoToTab 9; }
            bind "Alt 0" { GoToTab 10; }

            bind "Ctrl Shift f" { PageScrollDown; }
            bind "Ctrl Shift d" { HalfPageScrollDown; }
            bind "Ctrl Shift j" { ScrollDown; }
            bind "Ctrl Shift e" { ScrollToBottom; }
            bind "Ctrl Shift b" { PageScrollUp; }
            bind "Ctrl Shift u" { HalfPageScrollUp; }
            bind "Ctrl Shift k" { ScrollUp; }
          }
        }
      '';
    };
    layout = pkgs.writeTextFile {
      name = "scratch-term-zellij-layout";
      text = ''
        layout {
          pane size=1 borderless=true {
            plugin location="tab-bar"
          }
          pane
        }
      '';
    };
  in "zellij --config ${config} --layout ${layout} attach --create scratch-term";
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
    pbor.wm.hyprland.extra-settings = lib.mkOption {
      type = with lib.types; let
        valueType = oneOf [bool int float str path (attrsOf valueType) (listOf valueType)];
      in
        valueType;
      default = {};
      description = ''
        Extra Hyprland settings.
      '';
    };
    pbor.wm.hyprland.setting-providers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        An array of setting providers to enable.
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

        settings =
          lib.attrsets.recursiveUpdate
          {
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

            bind = let
              setting-providers = lib.concatMapStrings (p: "-p ${p} ") cfg.setting-providers;
            in [
              "$mod, space, exec, uwsm app -- hyprctl switchxkblayout main next"
              "$mod, Return, exec, uwsm app -- footclient"
              "$mod+Shift, Return, exec, uwsm app -- ${scratch-app}/bin/scratch-app -c term -- ${scratch-term-zellij}"
              "$mod, d, exec, uwsm app -- wofi -S run"
              "$mod+Shift, s, exec, uwsm app -- wofi-power-menu"
              "$mod+Shift, period, exec, uwsm app -- ${settings}/bin/settings ${setting-providers}"
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

              "$mod+Shift, bracketleft, movecurrentworkspacetomonitor, -1"
              "$mod+Shift, bracketright, movecurrentworkspacetomonitor, +1"

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
              "float, class:settings"
              "size 60% 60%, class:settings"
              "float, class:scratch-mail"
              "size 75% 90%, class:scratch-mail"

              "bordercolor rgb(${config.lib.stylix.colors.base08}), fullscreen:1"

              "float, class:steam"
            ];

            monitor = cfg.monitors;
            workspace = cfg.workspace-rules;
          }
          cfg.extra-settings;

        extraConfig = ''
          bind = $mod+Shift, r, submap, resize

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

      programs.zellij.enable = true;
      stylix.targets.zellij.enable = true;

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
