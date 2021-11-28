{ config, pkgs, lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";

      menu = "rofi -show run";
      terminal = "${pkgs.foot}/bin/foot";

      bindkeysToCode = true;
      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${modifier}+Return" = lib.mkForce null;
          "Mod1+Return" = "exec ${pkgs.foot}/bin/foot";
          "${modifier}+Shift+e" = "exec rofi -modi emoji -show emoji";

          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

      input = {
        "*" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:win_space_toggle";
        };
      };

      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-default.toml";
          fonts = {
            names = [ "MesloLGS Nerd Font Mono" "Font Awesome 5 Free" ];
            style = "Regular";
            size = 12.0;
          };
          colors = with config.lib.base16.theme; {
            background = "#${base00}";
            separator = "#${base01}";
            statusline = "#${base04}";
            focusedWorkspace = {
              border = "#${base05}";
              background = "#${base0D}";
              text = "#${base00}";
            };
            activeWorkspace = {
              border = "#${base05}";
              background = "#${base03}";
              text = "#${base00}";
            };
            inactiveWorkspace = {
              border = "#${base03}";
              background = "#${base01}";
              text = "#${base05}";
            };
            urgentWorkspace = {
              border = "#${base08}";
              background = "#${base08}";
              text = "#${base00}";
            };
            bindingMode = {
              border = "#${base00}";
              background = "#${base0A}";
              text = "#${base00}";
            };
          };
        }
      ];

      colors = with config.lib.base16.theme; {
        background = "#${base07}";
        focused = {
          border = "#${base05}";
          background = "#${base0D}";
          text = "#${base00}";
          indicator = "#${base0D}";
          childBorder = "#${base0D}";
        };
        focusedInactive = {
          border = "#${base01}";
          background = "#${base01}";
          text = "#${base05}";
          indicator = "#${base03}";
          childBorder = "#${base01}";
        };
        unfocused = {
          border = "#${base01}";
          background = "#${base00}";
          text = "#${base05}";
          indicator = "#${base01}";
          childBorder = "#${base01}";
        };
        urgent = {
          border = "#${base08}";
          background = "#${base08}";
          text = "#${base00}";
          indicator = "#${base08}";
          childBorder = "#${base08}";
        };
        placeholder = {
          border = "#${base00}";
          background = "#${base00}";
          text = "#${base05}";
          indicator = "#${base00}";
          childBorder = "#${base00}";
        };
      };
    };
  };

  services.dunst = {
    enable = true;

    settings = with config.lib.base16.theme; {
      global = {
        frame_color = "#${base05-hex}";
        separator_color = "#${base05-hex}";
      };

      base16_low = {
        msg_urgency = "low";
        background = "#${base01-hex}";
        foreground = "#${base03-hex}";
      };
      base16_normal = {
        msg_urgency = "normal";
        background = "#${base02-hex}";
        foreground = "#${base05-hex}";
      };
      base16_critical = {
        msg_urgency = "critical";
        background = "#${base08-hex}";
        foreground = "#${base06-hex}";
      };
    };
  };

  xdg.configFile =
    let
      theme = config.themes.base16.scheme;
    in
    {
      "i3status-rust-theme-${theme}" = with config.lib.base16.theme; {
        text = ''
          idle_bg = "#${base00-hex}"
          idle_fg = "#${base05-hex}"
          info_bg = "#${base0C-hex}"
          info_fg = "#${base00-hex}"
          good_bg = "#${base0B-hex}"
          good_fg = "#${base00-hex}"
          warning_bg = "#${base0A-hex}"
          warning_fg = "#${base00-hex}"
          critical_bg = "#${base08-hex}"
          critical_fg = "#${base00-hex}"
        '';
        target = "i3status-rust/themes/${theme}.toml";
      };
    };

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      theme = config.themes.base16.scheme;
      icons = "awesome5";
      blocks = [
        {
          block = "sound";
          driver = "pulseaudio";
          device_kind = "sink";
          headphones_indicator = true;
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
      ];
    };
  };

  programs.rofi =
    let
      theme = with config.lib.base16.theme; pkgs.writeText "rofi-theme" ''
        * {
            red:                         rgba ( ${base08-rgb-r}, ${base08-rgb-g}, ${base08-rgb-b}, 100 % );
            blue:                        rgba ( ${base0D-rgb-r}, ${base0D-rgb-g}, ${base0D-rgb-b}, 100 % );
            lightfg:                     rgba ( ${base06-rgb-r}, ${base06-rgb-g}, ${base06-rgb-b}, 100 % );
            lightbg:                     rgba ( ${base01-rgb-r}, ${base01-rgb-g}, ${base01-rgb-b}, 100 % );
            foreground:                  rgba ( ${base05-rgb-r}, ${base05-rgb-g}, ${base05-rgb-b}, 100 % );
            background:                  rgba ( ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b}, 100 % );
            background-color:            rgba ( ${base00-rgb-r}, ${base00-rgb-g}, ${base00-rgb-b}, 0 % );
            separatorcolor:              @foreground;
            border-color:                @foreground;
            selected-normal-foreground:  @lightbg;
            selected-normal-background:  @lightfg;
            selected-active-foreground:  @background;
            selected-active-background:  @blue;
            selected-urgent-foreground:  @background;
            selected-urgent-background:  @red;
            normal-foreground:           @foreground;
            normal-background:           @background;
            active-foreground:           @blue;
            active-background:           @background;
            urgent-foreground:           @red;
            urgent-background:           @background;
            alternate-normal-foreground: @foreground;
            alternate-normal-background: @lightbg;
            alternate-active-foreground: @blue;
            alternate-active-background: @lightbg;
            alternate-urgent-foreground: @red;
            alternate-urgent-background: @lightbg;
            spacing:                     2;
        }
        window {
            background-color: @background;
            border:           1;
            padding:          5;
        }
        mainbox {
            border:           0;
            padding:          0;
        }
        message {
            border:           1px dash 0px 0px ;
            border-color:     @separatorcolor;
            padding:          1px ;
        }
        textbox {
            text-color:       @foreground;
        }
        listview {
            fixed-height:     0;
            border:           2px dash 0px 0px ;
            border-color:     @separatorcolor;
            spacing:          2px ;
            scrollbar:        true;
            padding:          2px 0px 0px ;
        }
        element-text, element-icon {
            background-color: inherit;
            text-color:       inherit;
        }
        element {
            border:           0;
            padding:          1px ;
        }
        element normal.normal {
            background-color: @normal-background;
            text-color:       @normal-foreground;
        }
        element normal.urgent {
            background-color: @urgent-background;
            text-color:       @urgent-foreground;
        }
        element normal.active {
            background-color: @active-background;
            text-color:       @active-foreground;
        }
        element selected.normal {
            background-color: @selected-normal-background;
            text-color:       @selected-normal-foreground;
        }
        element selected.urgent {
            background-color: @selected-urgent-background;
            text-color:       @selected-urgent-foreground;
        }
        element selected.active {
            background-color: @selected-active-background;
            text-color:       @selected-active-foreground;
        }
        element alternate.normal {
            background-color: @alternate-normal-background;
            text-color:       @alternate-normal-foreground;
        }
        element alternate.urgent {
            background-color: @alternate-urgent-background;
            text-color:       @alternate-urgent-foreground;
        }
        element alternate.active {
            background-color: @alternate-active-background;
            text-color:       @alternate-active-foreground;
        }
        scrollbar {
            width:            4px ;
            border:           0;
            handle-color:     @normal-foreground;
            handle-width:     8px ;
            padding:          0;
        }
        sidebar {
            border:           2px dash 0px 0px ;
            border-color:     @separatorcolor;
        }
        button {
            spacing:          0;
            text-color:       @normal-foreground;
        }
        button selected {
            background-color: @selected-normal-background;
            text-color:       @selected-normal-foreground;
        }
        inputbar {
            spacing:          0px;
            text-color:       @normal-foreground;
            padding:          1px ;
            children:         [ prompt,textbox-prompt-colon,entry,case-indicator ];
        }
        case-indicator {
            spacing:          0;
            text-color:       @normal-foreground;
        }
        entry {
            spacing:          0;
            text-color:       @normal-foreground;
        }
        prompt {
            spacing:          0;
            text-color:       @normal-foreground;
        }
        textbox-prompt-colon {
            expand:           false;
            str:              ":";
            margin:           0px 0.3000em 0.0000em 0.0000em ;
            text-color:       inherit;
        }
      '';
    in
    {
      enable = true;
      package = pkgs.nur.repos.kira-bruneau.rofi-wayland;
      cycle = true;
      font = "MesloLGS Nerd Font Mono 12.0";
      location = "center";
      terminal = "${pkgs.foot}/bin/foot";
      plugins = [ pkgs.rofi-emoji ];
      extraConfig = {
        modi = "run";
      };
      theme = "${theme}";
    };
}

