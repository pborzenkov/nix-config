{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.helix = {
    enable = true;

    settings = {
      theme = config.scheme.slug;
      editor = {
        auto-pairs = false;
        cursor-shape = {
          insert = "bar";
        };
        indent-guides = {
          render = true;
        };
        line-number = "relative";
        mouse = false;
        shell = ["${pkgs.zsh}/bin/zsh" "-c"];
      };
    };

    languages = [
      {
        name = "cpp";
        auto-format = true;
      }
      {
        name = "nix";
        formatter = {
          command = "alejandra";
          args = ["-"];
        };
        auto-format = true;
      }
      {
        name = "eml";
        scope = "text.eml";
        roots = [];
        file-types = ["eml"];
        max-line-length = 72;
        rulers = [72];
      }
    ];
  };
}
