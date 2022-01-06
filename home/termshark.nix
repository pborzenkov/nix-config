{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.termshark
  ];

  xdg.configFile.termshark = {
    target = "termshark/termshark.toml";
    text = ''
      [main]
        colors = true
        dark-mode = true
    '';
  };
}
