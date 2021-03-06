{ config, pkgs, inputs, ... }:

{
  home.packages = [
    pkgs.helix
  ];

  xdg.configFile = {
    "helix/config.toml" = {
      source = (pkgs.formats.toml { }).generate "config.toml" {
        theme = config.scheme.slug;
        editor = {
          auto-pairs = false;
          line-number = "relative";
          mouse = false;
          shell = [ "${pkgs.zsh}/bin/zsh" "-c" ];
        };
      };
      target = "helix/config.toml";
    };

    "helix/languages.toml" = {
      source = (pkgs.formats.toml { }).generate "languages.toml" {
        language = [
          {
            name = "cpp";
            auto-format = true;
          }
          {
            name = "nix";
            auto-format = true;
          }
          {
            name = "perl";
            language-server = { command = "pls"; };
          }
          {
            name = "java";
            language-server = { command = "java-language-server"; };
          }
        ];
      };
    };
  };
}
