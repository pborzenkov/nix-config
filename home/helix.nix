{ config, pkgs, inputs, ... }:

{
  home.packages = [
    pkgs.helix
  ];

  xdg.configFile = {
    "helix/config.toml" = {
      source = (pkgs.formats.toml { }).generate "config.toml" {
        theme = "base16";
        editor = {
          line-number = "relative";
          mouse = false;
          shell = [ "${pkgs.zsh}/bin/zsh" "-c" ];
        };
      };
      target = "helix/config.toml";
    };

    "helix/themes/base16.toml" = {
      source = config.scheme inputs.base16-helix;
      target = "helix/themes/base16.toml";
    };
  };
}
