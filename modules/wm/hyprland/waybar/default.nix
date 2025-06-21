{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.hyprland.waybar;

  notifications = pkgs.writeShellApplication {
    name = "notifications";
    text = builtins.readFile ./scripts/notifications.sh;
    runtimeInputs = [ pkgs.dunst ];
  };
in
{
  options = {
    pbor.wm.hyprland.waybar.enable = (lib.mkEnableOption "Enable waybar") // {
      default = config.pbor.wm.hyprland.enable;
    };
    pbor.wm.hyprland.waybar.pulseaudio-icons = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
      default = null;
      description = ''Sound device mappings.'';
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
        programs.waybar = {
          enable = true;
          settings = {
            default = {
              layer = "top";
              position = "top";
              height = 24;

              modules-left = [
                "hyprland/workspaces"
                "hyprland/submap"
              ];
              modules-center = [ "hyprland/window" ];
              modules-right = [
                "idle_inhibitor"
                "custom/separator"
                "pulseaudio"
                "custom/separator"
                "hyprland/language"
                "custom/separator"
                "clock"
                "custom/separator"
                "custom/notifications"
                "custom/separator"
                "tray"
              ];

              "hyprland/submap" = {
                format = "[{}]";
              };

              idle_inhibitor = {
                format = "{icon}";
                format-icons = {
                  "activated" = "";
                  "deactivated" = "";
                };
              };

              pulseaudio = {
                format = "{icon} {volume}%";
                format-muted = "{icon} -";
                format-icons = cfg.pulseaudio-icons;
              };

              "hyprland/language" = {
                format-en = "EN";
                format-ru = "RU";
              };

              clock = {
                format = "{:%Y-%m-%d %H:%M}";
                tooltip-format = "<tt><small>{calendar}</small></tt>";
                calendar = {
                  mode = "year";
                  mode-mon-col = 3;
                  format = {
                    weeks = "{:%W}";
                    today = "<span color='#${config.lib.stylix.colors.base08}'><b><u>{}</u></b></span>";
                  };
                };
              };

              "custom/notifications" = {
                exec = "${notifications}/bin/notifications";
                on-click = "dunstctl set-paused toggle";
                restart-interval = 1;
              };

              tray = {
                spacing = 4;
              };

              "custom/separator" = {
                "format" = "|";
                "interval" = "once";
                "tooltip" = false;
              };
            };
          };
          style = ''
            * {
              font-family: "${config.stylix.fonts.monospace.name}", "Font Awesome 6 Free";
              min-height: 0;
            }

            window#waybar, tooltip {
              background: @base00;
              color: @base05;
            }

            #workspaces, #submap, #idle_inhibitor, #pulseaudio, #language, #clock, #custom-notifications, #tray {
              padding-left: 3px;
              padding-right: 3px;
            }

            #workspaces button {
              padding: 0 2px;
              margin: 0 2px;
            }

            #workspaces button.focused,
            #workspaces button.active {
              color: @base00;
              background: @base0D;
            }

            .modules-right > widget:last-child > #custom-separator {
              color: transparent;
            }
          '';
        };
        stylix.targets.waybar = {
          enable = true;
          addCss = false;
        };
        systemd.user.services.waybar = {
          Unit = {
            After = [ "graphical-session.target" ];
          };

          Service = {
            Type = "exec";
            ExecCondition = ''${pkgs.systemd}/lib/systemd/systemd-xdg-autostart-condition "Hyprland" ""'';
            ExecStart = "${lib.getExe config.programs.waybar.package}";
            Restart = "on-failure";
            Slice = "background-graphical.slice";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
