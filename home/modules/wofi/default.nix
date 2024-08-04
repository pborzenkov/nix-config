{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.wofi;
in {
  options = {
    pbor.wofi.enable = (lib.mkEnableOption "Enable zathura") // {default = config.pbor.enable && isDesktop;};
    pbor.wofi.menu = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf (lib.types.submodule {
        options = {
          title = lib.mkOption {
            type = lib.types.str;
            description = ''Entry title.'';
          };
          cmd = lib.mkOption {
            type = lib.types.str;
            description = ''Command to run.'';
          };
          icon = lib.mkOption {
            type = lib.types.str;
            description = ''Entry icon.'';
          };
          confirmation = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''Whether the entry requires confirmation or not.'';
          };
        };
      }));
    };
  };

  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      settings = {
        mode = "run";
        location = "center";
        term = "foot";

        matching = "fuzzy";
        insensitive = "true";

        key_down = "Ctrl-n";
        key_up = "Ctrl-p";
      };
    };
    stylix.targets.wofi.enable = true;

    home.packages = [
      pkgs.nur.repos.pborzenkov.wofi-power-menu
    ];

    xdg.configFile."wofi-power-menu.toml".source = (pkgs.formats.toml {}).generate "wofi-power-menu.toml" {
      wofi = {
        extra_args = "--width 20% --allow-markup --columns=1 --hide-scroll";
      };
      menu =
        {
          logout = {
            cmd = "loginctl terminate-session self";
            requires_confirmation = "true";
          };
          suspend.requires_confirmation = "false";
          hibernate.enabled = "false";
        }
        // (builtins.mapAttrs (_: entry: {
            title = entry.title;
            cmd = entry.cmd;
            icon = entry.icon;
            requires_confirmation = lib.boolToString entry.confirmation;
          })
          cfg.menu);
    };
  };
}
