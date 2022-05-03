{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.termshark
  ];

  xdg.configFile.termshark = {
    source = (pkgs.formats.toml { }).generate "termshark.toml" {
      main = {
        colors = true;
        dark-mode = true;
      };
    };
    target = "termshark/termshark.toml";
  };
}
