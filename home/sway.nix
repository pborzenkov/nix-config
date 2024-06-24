{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  scratchTerm = pkgs.writeShellScript "scratch-term.sh" ''
    jq=${pkgs.jq}/bin/jq
    tree=$(${pkgs.sway}/bin/swaymsg -t get_tree)
    cw=$(echo $tree | $jq -r '.nodes[] | select(has("current_workspace")) | .current_workspace')
    cwt=$(echo $tree | $jq '.nodes[].nodes[] | select(.name == "'$cw'")')

    [ -n "$(echo $tree | $jq '.. | objects | select ( .app_id == "scratch-term")')" ] && is_running=1 || is_running=0
    is_visible=0
    [ -n "$(echo $cwt | $jq '.nodes[] | select(.app_id == "scratch-term")')" ] && is_visible=1 || is_visible=0

    [ $is_running -eq 0 ] && exec ${pkgs.foot}/bin/foot -a scratch-term ${pkgs.zellij}/bin/zellij attach -c scratch
    [ $is_visible -eq 0 ] && exec ${pkgs.sway}/bin/swaymsg '[con_mark="scratch-term"] scratchpad show, [con_mark="scratch-term"] move to workspace $cw'

    exec ${pkgs.sway}/bin/swaymsg '[con_mark="scratch-term"] move scratchpad'
  '';
in {
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";

      menu = "wofi -S run";
      terminal = "${pkgs.foot}/bin/foot";

      bindkeysToCode = true;
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in {
        "${modifier}+d" = "exec wofi -S run";
        "Mod1+Shift+Return" = "exec ${scratchTerm}";
        "${modifier}+Shift+s" = ''exec wofi-power-menu'';
        "${modifier}+q" = "kill";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+F1" = "focus output DP-4";
        "${modifier}+F2" = "focus output eDP-1";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";

        "${modifier}+Shift+F1" = "move workspace to output DP-4";
        "${modifier}+Shift+F2" = "move workspace to output eDP-1";

        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+r" = "mode resize";
        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+minus" = "scratchpad show";

        "${modifier}+bracketleft" = "focus parent";
        "${modifier}+bracketright" = "focus child";
        "${modifier}+v" = "splith";
        "${modifier}+b" = "splitv";

        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl -p mpd previous";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl -p mpd next";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl -p mpd play-pause";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        Print = ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - | ${pkgs.wl-clipboard}/bin/wl-copy'';
        "Shift+Print" = ''exec ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)"'';
        "Ctrl+Print" = ''exec ${pkgs.grim}/bin/grim -o $(${pkgs.sway}/bin/swaymsg -t get_outputs | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name') - | ${pkgs.wl-clipboard}/bin/wl-copy'';
        "Ctrl+Shift+Print" = ''exec ${pkgs.grim}/bin/grim -o $(${pkgs.sway}/bin/swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')'';

        "${modifier}+Shift+n" = "exec dunstctl set-paused toggle";

        "${modifier}+Shift+c" = "reload";
      };

      input = {
        "*" = {
          xkb_layout = " us,ru";
          xkb_options = "grp:win_space_toggle,caps:escape";
        };
      };

      output = {
        "*" = {
          bg = "${inputs.self}/assets/wallpaper.jpg fill";
        };
      };

      seat = {
        "*" = {
          "xcursor_theme" = "capitaine-cursors 24";
          "hide_cursor" = "when-typing enable";
        };
      };

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-default.toml";
          fonts = {
            names = ["MesloLGS Nerd Font Mono" "Font Awesome 6 Free"];
            style = "Regular";
            size = 10.0;
          };
          colors = with config.scheme.withHashtag; {
            background = base00;
            separator = base03;
            statusline = base04;
            focusedWorkspace = {
              border = base05;
              background = base0D;
              text = base00;
            };
            activeWorkspace = {
              border = base05;
              background = base03;
              text = base00;
            };
            inactiveWorkspace = {
              border = base03;
              background = base01;
              text = base05;
            };
            urgentWorkspace = {
              border = base08;
              background = base08;
              text = base00;
            };
            bindingMode = {
              border = base00;
              background = base0A;
              text = base00;
            };
          };
        }
      ];

      colors = with config.scheme.withHashtag; {
        background = base07;
        focused = {
          border = base05;
          background = base0D;
          text = base00;
          indicator = base0D;
          childBorder = base0D;
        };
        focusedInactive = {
          border = base01;
          background = base01;
          text = base05;
          indicator = base03;
          childBorder = base01;
        };
        unfocused = {
          border = base01;
          background = base00;
          text = base05;
          indicator = base01;
          childBorder = base01;
        };
        urgent = {
          border = base08;
          background = base08;
          text = base00;
          indicator = base08;
          childBorder = base08;
        };
        placeholder = {
          border = base00;
          background = base00;
          text = base05;
          indicator = base00;
          childBorder = base00;
        };
      };

      window.commands = [
        {
          criteria = {app_id = "zoom";};
          command = "floating enable";
        }
        {
          criteria = {app_id = "scratch-term";};
          command = ''mark "scratch-term", move scratchpad, resize set 1128 758, scratchpad show'';
        }
        {
          criteria = {
            app_id = "firefox";
            title = "Firefox — Sharing Indicator";
          };
          command = "move scratchpad";
        }
      ];
      startup = [
        {command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK";}
        {command = "system --user import-environment";}
      ];
    };
    extraConfig = ''
      hide_edge_borders --i3 none
    '';
  };

  systemd.user.services.swayidle = {
    Unit = {
      Description = "Idle manager for Wayland";
      PartOf = ["sway-session.target"];
      After = ["sway-session.target"];
    };

    Service = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "1sec";
      Environment = ["PATH=${dirOf pkgs.stdenv.shell}:/usr/bin"];
      ExecStart = "swayidle -w";
    };
    Install.WantedBy = ["sway-session.target"];
  };

  services.dunst = {
    enable = true;

    settings = with config.scheme.withHashtag; {
      global = {
        frame_color = base05-hex;
        separator_color = base05-hex;
      };

      base16_low = {
        msg_urgency = "low";
        background = base01;
        foreground = base03;
      };
      base16_normal = {
        msg_urgency = "normal";
        background = base02;
        foreground = base05;
      };
      base16_critical = {
        msg_urgency = "critical";
        background = base08;
        foreground = base06;
      };
    };
  };

  xdg.configFile = {
    "swaylock/config" = with config.scheme; {
      text = ''
        font=MesloLGS Nerd Font Mono

        color=${base00}

        key-hl-color=${base0B}

        separator-color=00000000

        inside-color=${base00}
        inside-clear-color=${base00}
        inside-ver-color=${base0D}
        inside-wrong-color=${base08}

        ring-color=${base01}
        ring-clear-color=${base01}
        ring-ver-color=${base0D}
        ring-wrong-color=${base08}

        line-color=00000000
        line-clear-color=00000000
        line-ver-color=00000000
        line-wrong-color=00000000

        text-clear-color=${base09}
        text-caps-lock-color=${base09}
        text-ver-color=${base00}
        text-wrong-color=${base00}

        bs-hl-color=${base08}

        ignore-empty-password

        indicator-idle-visible
        indicator-radius=130
        indicator-thickness=15
      '';
      target = "swaylock/config";
    };
    "swayidle/config" = {
      text = ''
        timeout 300 'swaylock -f'
        timeout 600 '${pkgs.sway}/bin/swaymsg "output * dpms off"' resume '${pkgs.sway}/bin/swaymsg "output * dpms on"'
        timeout 900 '${pkgs.systemd}/bin/systemctl suspend' resume '${pkgs.sway}/bin/swaymsg "output * dpms on"'
        before-sleep 'swaylock -f'
        lock 'swaylock -f'
      '';
      target = "swayidle/config";
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      settings = {
        icons = lib.mkForce {
          icons = "awesome6";
        };
        theme = {
          theme = "native"; # fully overwritten
          overrides = with config.scheme.withHashtag; {
            idle_bg = base00;
            idle_fg = base05;
            info_bg = base0C;
            info_fg = base00;
            good_bg = base0B;
            good_fg = base00;
            warning_bg = base0A;
            warning_fg = base00;
            critical_bg = base08;
            critical_fg = base00;
          };
        };
      };
    };
  };
  home = {
    sessionVariables = {
      GRIM_DEFAULT_DIR = "${config.home.homeDirectory}/down";
    };
  };
}
