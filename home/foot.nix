{ config, pkgs, ... }:

{
  programs.foot = {
    enable = true;

    settings = {
      main = {
        term = "xterm-256color";

        font = "MesloLGS Nerd Font Mono:size=12";
        dpi-aware = "yes";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors = with config.lib.base16.theme; {
        foreground = base05-hex;
        background = base00-hex;

        regular0 = base00-hex;
        regular1 = base08-hex;
        regular2 = base0B-hex;
        regular3 = base0A-hex;
        regular4 = base0D-hex;
        regular5 = base0E-hex;
        regular6 = base0C-hex;
        regular7 = base05-hex;

        bright0 = base03-hex;
        bright1 = base08-hex;
        bright2 = base0B-hex;
        bright3 = base0A-hex;
        bright4 = base0D-hex;
        bright5 = base0E-hex;
        bright6 = base0C-hex;
        bright7 = base07-hex;
        "16" = base09-hex;
        "17" = base0F-hex;
        "18" = base01-hex;
        "19" = base02-hex;
        "20" = base04-hex;
        "21" = base06-hex;
      };

      cursor = with config.lib.base16.theme; {
        color = "${base00-hex} ${base05-hex}";
      };
    };
  };
}
