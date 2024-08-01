{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.helix;
in {
  options = {
    pbor.helix.enable = (lib.mkEnableOption "Enable helix") // {default = true;};
  };

  config = lib.mkIf cfg.enable {
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
          shell = ["fish" "-c"];
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
        ];
      };
    };
    stylix.targets.helix.enable = true;

    home.sessionVariables = {
      EDITOR = "hx";
    };
  };
}
