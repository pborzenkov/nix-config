{ config, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    server.enable = true;

    settings = {
      main = {
        term = "xterm-256color";

        font = "MesloLGS Nerd Font Mono:size=12";
        dpi-aware = "yes";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
