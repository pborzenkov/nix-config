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
    ];
  };
}
