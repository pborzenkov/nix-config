{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      window = {
        dimensions = {
          columns = 0;
          lines = 0;
        };
        padding = {
          x = 2;
          y = 2;
        };
        dynamic_title = true;
        opacity = 1.0;
      };

      scrolling = {
        history = 1000;
        multiplier = 1;
      };

      alt_send_esc = true;

      font = {
        normal = {
          family = "MesloLGS Nerd Font Mono";
          style = "Regular";
        };

        bold = {
          family = "MesloLGS Nerd Font Mono";
          style = "Bold";
        };

        italic = {
          family = "MesloLGS Nerd Font Mono";
          style = "Italic";
        };

        size = 12.0;

        offset = {
          x = 0;
          y = 0;
        };

        glyph_offset = {
          x = 0;
          y = 0;
        };

        use_thin_strokes = true;
      };

      debug.render_timer = false;

      bell = {
        animation = "EaseOutExpo";
        duration = 0;
      };

      mouse_bindings = [
        { mouse = "Middle"; action = "PasteSelection"; }
      ];

      mouse = {
        double_click = { threshold = 300; };
        tripple_click = { threshold = 300; };

        faux_scrolling_lines = 1;
        hide_when_typing = true;
      };

      key_bindings = [
        { key = "A"; mods = "Alt"; chars = "\\x1ba"; }
        { key = "B"; mods = "Alt"; chars = "\\x1bb"; }
        { key = "C"; mods = "Alt"; chars = "\\x1bc"; }
        { key = "D"; mods = "Alt"; chars = "\\x1bd"; }
        { key = "E"; mods = "Alt"; chars = "\\x1be"; }
        { key = "F"; mods = "Alt"; chars = "\\x1bf"; }
        { key = "G"; mods = "Alt"; chars = "\\x1bg"; }
        { key = "H"; mods = "Alt"; chars = "\\x1bh"; }
        { key = "I"; mods = "Alt"; chars = "\\x1bi"; }
        { key = "J"; mods = "Alt"; chars = "\\x1bj"; }
        { key = "K"; mods = "Alt"; chars = "\\x1bk"; }
        { key = "L"; mods = "Alt"; chars = "\\x1bl"; }
        { key = "M"; mods = "Alt"; chars = "\\x1bm"; }
        { key = "N"; mods = "Alt"; chars = "\\x1bn"; }
        { key = "O"; mods = "Alt"; chars = "\\x1bo"; }
        { key = "P"; mods = "Alt"; chars = "\\x1bp"; }
        { key = "Q"; mods = "Alt"; chars = "\\x1bq"; }
        { key = "R"; mods = "Alt"; chars = "\\x1br"; }
        { key = "S"; mods = "Alt"; chars = "\\x1bs"; }
        { key = "T"; mods = "Alt"; chars = "\\x1bt"; }
        { key = "U"; mods = "Alt"; chars = "\\x1bu"; }
        { key = "V"; mods = "Alt"; chars = "\\x1bv"; }
        { key = "W"; mods = "Alt"; chars = "\\x1bw"; }
        { key = "X"; mods = "Alt"; chars = "\\x1bx"; }
        { key = "Y"; mods = "Alt"; chars = "\\x1by"; }
        { key = "Z"; mods = "Alt"; chars = "\\x1bz"; }

        { key = "A"; mods = "Alt|Shift"; chars = "\\x1bA"; }
        { key = "B"; mods = "Alt|Shift"; chars = "\\x1bB"; }
        { key = "C"; mods = "Alt|Shift"; chars = "\\x1bC"; }
        { key = "D"; mods = "Alt|Shift"; chars = "\\x1bD"; }
        { key = "E"; mods = "Alt|Shift"; chars = "\\x1bE"; }
        { key = "F"; mods = "Alt|Shift"; chars = "\\x1bF"; }
        { key = "G"; mods = "Alt|Shift"; chars = "\\x1bG"; }
        { key = "H"; mods = "Alt|Shift"; chars = "\\x1bH"; }
        { key = "I"; mods = "Alt|Shift"; chars = "\\x1bI"; }
        { key = "J"; mods = "Alt|Shift"; chars = "\\x1bJ"; }
        { key = "K"; mods = "Alt|Shift"; chars = "\\x1bK"; }
        { key = "L"; mods = "Alt|Shift"; chars = "\\x1bL"; }
        { key = "M"; mods = "Alt|Shift"; chars = "\\x1bM"; }
        { key = "N"; mods = "Alt|Shift"; chars = "\\x1bN"; }
        { key = "O"; mods = "Alt|Shift"; chars = "\\x1bO"; }
        { key = "P"; mods = "Alt|Shift"; chars = "\\x1bP"; }
        { key = "Q"; mods = "Alt|Shift"; chars = "\\x1bQ"; }
        { key = "R"; mods = "Alt|Shift"; chars = "\\x1bR"; }
        { key = "S"; mods = "Alt|Shift"; chars = "\\x1bS"; }
        { key = "T"; mods = "Alt|Shift"; chars = "\\x1bT"; }
        { key = "U"; mods = "Alt|Shift"; chars = "\\x1bU"; }
        { key = "V"; mods = "Alt|Shift"; chars = "\\x1bV"; }
        { key = "W"; mods = "Alt|Shift"; chars = "\\x1bW"; }
        { key = "X"; mods = "Alt|Shift"; chars = "\\x1bX"; }
        { key = "Y"; mods = "Alt|Shift"; chars = "\\x1bY"; }
        { key = "Z"; mods = "Alt|Shift"; chars = "\\x1bZ"; }

        { key = "Key1"; mods = "Alt"; chars = "\\x1b1"; }
        { key = "Key2"; mods = "Alt"; chars = "\\x1b2"; }
        { key = "Key3"; mods = "Alt"; chars = "\\x1b3"; }
        { key = "Key4"; mods = "Alt"; chars = "\\x1b4"; }
        { key = "Key5"; mods = "Alt"; chars = "\\x1b5"; }
        { key = "Key6"; mods = "Alt"; chars = "\\x1b6"; }
        { key = "Key7"; mods = "Alt"; chars = "\\x1b7"; }
        { key = "Key8"; mods = "Alt"; chars = "\\x1b8"; }
        { key = "Key9"; mods = "Alt"; chars = "\\x1b9"; }
        { key = "Key0"; mods = "Alt"; chars = "\\x1b0"; }

        { key = "Slash"; mods = "Alt"; chars = "\\x1b/"; }
        { key = "Semicolon"; mods = "Alt"; chars = "\\x1b;"; }
        { key = "LBracket"; mods = "Alt"; chars = "\\x1b["; }
        { key = "RBracket"; mods = "Alt"; chars = "\\x1b]"; }
      ];

      selection.semantic_escape_chars = ",|`│:\"' ()[]{}<>";

      cursor.style = "Block";

      live_config_reload = true;

      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [
          "--login"
        ];
      };

      colors = with config.lib.base16.theme; {
        primary = {
          background = "0x${base00}";
          foreground = "0x${base05}";
        };

        cursor = {
          text = "0x${base00}";
          cursor = "0x${base05}";
        };

        normal = {
          black = "0x${base00}";
          red = "0x${base08}";
          green = "0x${base0B}";
          yellow = "0x${base0A}";
          blue = "0x${base0D}";
          magenta = "0x${base0E}";
          cyan = "0x${base0C}";
          white = "0x${base05}";
        };

        bright = {
          black = "0x${base03}";
          red = "0x${base08}";
          green = "0x${base0B}";
          yellow = "0x${base0A}";
          blue = "0x${base0D}";
          magenta = "0x${base0E}";
          cyan = "0x${base0C}";
          white = "0x${base07}";
        };

        indexed_colors = [
          { index = 16; color = "0x${base09}"; }
          { index = 17; color = "0x${base0F}"; }
          { index = 18; color = "0x${base01}"; }
          { index = 19; color = "0x${base02}"; }
          { index = 20; color = "0x${base04}"; }
          { index = 21; color = "0x${base06}"; }
        ];
      };
    };
  };
}
