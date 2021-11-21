{ config, pkgs, lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";

      menu = "${pkgs.bemenu}/bin/bemenu-run -i -p \\>";
      terminal = "${pkgs.foot}/bin/foot";

      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${modifier}+Return" = lib.mkForce null;
          "Mod1+Return" = "exec ${pkgs.foot}/bin/foot";
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
          block = "time";
          interval = 60;
          format = "%a %d/%m %R";
        }
      ];
    };
  };
}
