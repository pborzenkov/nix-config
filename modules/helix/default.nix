{
  config,
  lib,
  ...
}:
let
  cfg = config.pbor.helix;
in
{
  options = {
    pbor.helix.enable = (lib.mkEnableOption "Enable helix") // {
      default = config.pbor.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      {
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
              shell = [
                "fish"
                "-c"
              ];
              soft-wrap = {
                enable = true;
              };
              statusline = {
                right = [
                  "version-control"
                  "diagnostics"
                  "selections"
                  "position"
                  "file-encoding"
                ];
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
                  command = "nixfmt";
                };
                auto-format = true;
              }
            ];
          };
        };

        home.sessionVariables = {
          EDITOR = "hx";
        };
      }
      // lib.optionalAttrs config.pbor.stylix.enable {
        stylix.targets.helix.enable = true;
      };
  };
}
