{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  scratch-term = pkgs.writeShellApplication {
    name = "scratch-term";
    text = builtins.readFile "${inputs.self}/home/sway/scratch-term.sh";
    runtimeInputs = [pkgs.sway pkgs.jq pkgs.foot];
  };
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    text = builtins.readFile "${inputs.self}/home/sway/screenshot.sh";
    runtimeInputs = [pkgs.sway pkgs.jq pkgs.grim pkgs.slurp pkgs.wl-clipboard];
  };
in {
  wayland.windowManager.sway = {
    enable = true;
    package = null;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      bindkeysToCode = true;
      keybindings = let
        cfg = config.wayland.windowManager.sway.config;
      in {
        "${cfg.modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
        "${cfg.modifier}+Shift+Return" = "exec ${scratch-term}/bin/scratch-term toggle";

        "${cfg.modifier}+d" = "exec ${pkgs.wofi}/bin/wofi -S run";
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

        "${cfg.modifier}+Shift+n" = "exec ${pkgs.dunst}/bin/dunstctl set-paused toggle";

        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl -p mpd previous";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl -p mpd next";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl -p mpd play-pause";

        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";

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
    systemd = {
      enable = true;
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
