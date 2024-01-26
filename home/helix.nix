{
  config,
  pkgs,
  ...
}: {
  programs.helix = {
    enable = true;

    settings = {
      editor = {
        auto-pairs = false;
        cursor-shape = {
          insert = "bar";
        };
        indent-guides = {
          render = true;
        };
        line-number = "relative";
        lsp = {
          display-inlay-hints = false;
        };
        mouse = false;
        shell = ["${pkgs.zsh}/bin/zsh" "-c"];
        soft-wrap = {
          enable = true;
        };
        statusline = {
          right = ["version-control" "diagnostics" "selections" "position" "file-encoding"];
        };
      };
      keys.normal.space = {
        H = ":toggle lsp.display-inlay-hints";
      };
      theme = config.scheme.slug;
    };

    languages = {
      language-server.rust-analyzer.config = {
        check.command = "clippy";
      };

      language = [
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
          text-width = 72;
          rulers = [72];
        }
      ];
    };
  };
}
