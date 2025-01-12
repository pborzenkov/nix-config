{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}: let
  cfg = config.pbor.wm.sway;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.wm.sway.enable = (lib.mkEnableOption "Enable Sway") // {default = config.pbor.wm.enable;};
    pbor.wm.sway.output = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = {};
      description = ''
        An attribute set that defines output modules.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraSessionCommands = ''
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export SDL_VIDEODRIVER=wayland
        source ${config.hm.home.profileDirectory}/etc/profile.d/hm-session-vars.sh
      '';
    };

    xdg.portal = {
      config.sway = {
        default = "gtk";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Inhibit" = "none";
      };
    };

    hm = {config, ...}: let
      scratch-term = pkgs.writeShellApplication {
        name = "scratch-term";
        text = builtins.readFile ./scripts/scratch-term.sh;
        runtimeInputs = [pkgs.sway pkgs.jq pkgs.foot];
      };
      screenshot = pkgs.writeShellApplication {
        name = "screenshot";
        text = builtins.readFile ./scripts/screenshot.sh;
        runtimeEnv = {
          GRIM_DEFAULT_DIR = "${config.home.homeDirectory}/down";
        };
        runtimeInputs = [pkgs.sway pkgs.jq pkgs.grim pkgs.slurp pkgs.wl-clipboard];
      };
    in {
      wayland.windowManager.sway = {
        enable = true;
        package = null;
        systemd.enable = true;

        config = {
          modifier = "Mod4";
          bindkeysToCode = true;
          keybindings = let
            cfg = config.wayland.windowManager.sway.config;
          in {
            "${cfg.modifier}+Return" = "exec foot";
            "${cfg.modifier}+Shift+Return" = "exec ${scratch-term}/bin/scratch-term toggle";

            "${cfg.modifier}+d" = "exec wofi -S run";
            "${cfg.modifier}+Shift+s" = "exec wofi-power-menu";

            "${cfg.modifier}+q" = "kill";

            "${cfg.modifier}+h" = "focus left";
            "${cfg.modifier}+j" = "focus down";
            "${cfg.modifier}+k" = "focus up";
            "${cfg.modifier}+l" = "focus right";

            "${cfg.modifier}+Shift+h" = "move left";
            "${cfg.modifier}+Shift+j" = "move down";
            "${cfg.modifier}+Shift+k" = "move up";
            "${cfg.modifier}+Shift+l" = "move right";

            "${cfg.modifier}+b" = "splitb";
            "${cfg.modifier}+v" = "splitv";
            "${cfg.modifier}+f" = "fullscreen toggle";
            "${cfg.modifier}+a" = "focus parent";
            "${cfg.modifier}+c" = "focus child";

            "${cfg.modifier}+s" = "layout stacking";
            "${cfg.modifier}+w" = "layout tabbed";
            "${cfg.modifier}+e" = "layout toggle split";

            "${cfg.modifier}+Shift+space" = "floating toggle";

            "${cfg.modifier}+1" = "workspace number 1";
            "${cfg.modifier}+2" = "workspace number 2";
            "${cfg.modifier}+3" = "workspace number 3";
            "${cfg.modifier}+4" = "workspace number 4";
            "${cfg.modifier}+5" = "workspace number 5";
            "${cfg.modifier}+6" = "workspace number 6";
            "${cfg.modifier}+7" = "workspace number 7";
            "${cfg.modifier}+8" = "workspace number 8";
            "${cfg.modifier}+9" = "workspace number 9";

            "${cfg.modifier}+Shift+1" = "move container to workspace number 1";
            "${cfg.modifier}+Shift+2" = "move container to workspace number 2";
            "${cfg.modifier}+Shift+3" = "move container to workspace number 3";
            "${cfg.modifier}+Shift+4" = "move container to workspace number 4";
            "${cfg.modifier}+Shift+5" = "move container to workspace number 5";
            "${cfg.modifier}+Shift+6" = "move container to workspace number 6";
            "${cfg.modifier}+Shift+7" = "move container to workspace number 7";
            "${cfg.modifier}+Shift+8" = "move container to workspace number 8";
            "${cfg.modifier}+Shift+9" = "move container to workspace number 9";

            "${cfg.modifier}+r" = "mode resize";

            "${cfg.modifier}+Shift+n" = "exec dunstctl set-paused toggle";

            "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "${cfg.modifier}+less" = "exec wofi-sound-menu input";
            "${cfg.modifier}+greater" = "exec wofi-sound-menu output";

            "XF86AudioPrev" = "exec playerctl -p mpd previous";
            "XF86AudioNext" = "exec playerctl -p mpd next";
            "XF86AudioPlay" = "exec playerctl -p mpd play-pause";

            "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
            "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

            "Print" = "exec ${screenshot}/bin/screenshot select-copy";
            "Shift+Print" = "exec ${screenshot}/bin/screenshot select-file";
            "Ctrl+Print" = "exec ${screenshot}/bin/screenshot fullscreen-copy";
            "Ctrl+Shift+Print" = "exec ${screenshot}/bin/screenshot fullscreen-file";
          };

          focus = {
            followMouse = false;
            wrapping = "no";
          };

          input = {
            "*" = {
              xkb_layout = "us,ru";
              xkb_options = "grp:win_space_toggle,caps:escape,compose:paus";
            };
          };

          output = cfg.output;

          seat."*" = {
            "hide_cursor" = "when-typing enable";
          };

          bars = [
            (lib.attrsets.recursiveUpdate
              config.lib.stylix.sway.bar
              {
                position = "top";
                statusCommand = "i3status-rs ${config.xdg.configHome}/i3status-rust/config-default.toml";
                fonts = {
                  names = [config.stylix.fonts.monospace.name "Font Awesome 6 Free"];
                };
                colors.focusedWorkspace.text = config.lib.stylix.colors.withHashtag.base00;
              })
          ];

          window.commands = [
            {
              criteria = {app_id = "scratch-term";};
              command = "split vertical, layout tabbed, mark scratch-term-finalize";
            }
            {
              criteria = {con_mark = "scratch-term-finalize";};
              command = "exec ${scratch-term}/bin/scratch-term finalize";
            }
            {
              criteria = {
                app_id = "firefox";
                title = "Firefox — Sharing Indicator";
              };
              command = "move scratchpad";
            }
            {
              criteria = {
                class = "steam";
              };
              command = "floating enable, move to workspace 9";
            }
          ];
        };

        extraConfig = ''
          hide_edge_borders --i3 none
        '';
      };
      stylix.targets.sway.enable = true;
    };
  };
}
