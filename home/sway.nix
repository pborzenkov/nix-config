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

    [ $is_running -eq 0 ] && exec ${pkgs.foot}/bin/foot -a scratch-term tmux new-session -s scratch
    [ $is_visible -eq 0 ] && exec ${pkgs.sway}/bin/swaymsg '[con_mark="scratch-term"] scratchpad show, [con_mark="scratch-term"] move to workspace $cw'

    exec ${pkgs.sway}/bin/swaymsg '[con_mark="scratch-term"] move scratchpad'
  '';
  launcher = pkgs.writeShellScript "launcher.sh" ''
    programs=(
      "bashmount"
      "ncpamixer"
    )
    exec $(printf "%s\n" ''${programs[@]} | ${pkgs.skim}/bin/sk)
  '';
  launcherTerm = pkgs.writeShellScript "launcher-term.sh" ''
    exec ${pkgs.foot}/bin/foot -W 160x50 -a launcher-term ${launcher}
  '';
in {
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";

      menu = "rofi -show run";
      terminal = "${pkgs.foot}/bin/foot";

      bindkeysToCode = true;
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in
        lib.mkOptionDefault {
          "${modifier}+Return" = lib.mkForce null;
          "${modifier}+space" = lib.mkForce null;
          "Mod1+Return" = "exec ${scratchTerm}";
          "Mod1+Shift+Return" = "exec ${launcherTerm}";
          "${modifier}+Shift+e" = "exec rofi -modi emoji -show emoji";
          "${modifier}+Shift+s" = ''
            exec rofi -theme-str 'window {width: 20%;} listview{scrollbar: false; lines: 6;}' \
            -show power \
            -modi "power:${pkgs.nur.repos.pborzenkov.rofi-power-menu}/bin/rofi-power-menu --choices lockscreen/logout/reboot/shutdown/suspend/windows"
          '';

          "${modifier}+bracketleft" = "focus parent";
          "${modifier}+bracketright" = "focus child";
          "${modifier}+v" = "splith";
          "${modifier}+b" = "splitv";

          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "${modifier}+braceleft" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "${modifier}+braceright" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "${modifier}+bar" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";

          "${modifier}+Shift+n" = "exec dunstctl set-paused toggle";
        };

      input = {
        "*" = {
          xkb_layout = " us,ru";
          xkb_options = "grp:win_space_toggle";
        };
      };

      output = {
        "*" = {
          bg = "${config.xdg.dataHome}/sway/wallpaper.jpg fill";
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
            names = ["MesloLGS Nerd Font Mono" "Font Awesome 5 Free"];
            style = "Regular";
            size = 12.0;
          };
          colors = with config.scheme.withHashtag; {
            background = base00;
            separator = base01;
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
          command = ''mark "scratch-term", move scratchpad, scratchpad show, resize set 1128 758'';
        }
        {
          criteria = {app_id = "launcher-term";};
          command = "floating enable";
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
      ];
    };
  };

  xdg.dataFile."wallpaper.jpg" = {
    source = ../assets/wallpaper.jpg;
    target = "sway/wallpaper.jpg";
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
      Environment = ["PATH=${dirOf pkgs.stdenv.shell}:$PATH"];
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w";
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
        timeout 300 '${pkgs.swaylock}/bin/swaylock -f'
        timeout 600 '${pkgs.sway}/bin/swaymsg "output * dpms off"' resume '${pkgs.sway}/bin/swaymsg "output * dpms on"'
        timeout 900 '${pkgs.systemd}/bin/systemctl suspend' resume '${pkgs.sway}/bin/swaymsg "output * dpms on"'
        before-sleep '${pkgs.swaylock}/bin/swaylock -f'
        lock '${pkgs.swaylock}/bin/swaylock -f'
      '';
      target = "swayidle/config";
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      icons = "awesome5";
      blocks = [
        {
          block = "sound";
          driver = "pulseaudio";
          device_kind = "sink";
          format = "{output_name}{volume}";
          mappings = {
            "alsa_output.usb-Razer_Razer_USB_Sound_Card_00000000-00.analog-stereo" = " ";
            "alsa_output.pci-0000_12_00.4.analog-stereo" = "";
          };
          on_click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        }
        {
          block = "sound";
          driver = "pulseaudio";
          device_kind = "source";
          on_click = "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        }
        {
          block = "keyboard_layout";
          driver = "sway";
          format = "{layout}";
          mappings = {
            "English (US)" = "EN";
            "Russian (N/A)" = "RU";
          };
        }
        {
          block = "time";
          interval = 60;
          format = "%a %d/%m %R";
        }
        {
          block = "notify";
          format = "";
        }
      ];
      settings = {
        theme = {
          name = "solarized-dark"; # fully overwritten
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
}
