{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.niri;
in
{
  imports = pborlib.allDirs ./.;

  options = {
    pbor.wm.niri.enable = (lib.mkEnableOption "Enable Niri") // {
      default = config.pbor.wm.enable;
    };
    pbor.wm.niri.extra-settings = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Extra Niri settings
      '';
    };
    pbor.wm.niri.extra-binds = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        Extra Niri binds
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      niri.enable = true;
      uwsm = {
        enable = true;
        waylandCompositors.niri = {
          prettyName = "Niri";
          comment = "Niri compositor managed by UWSM";
          binPath = pkgs.writeShellScript "niri" ''
            ${lib.getExe config.programs.niri.package} --session
          '';
        };
      };
    };

    hm =
      { config, ... }:
      {
        xdg.configFile."niri/config.kdl".text =
          with config.lib.stylix.colors.withHashtag;
          ''
            prefer-no-csd
            input {
              keyboard {
                xkb {
                  layout "us,ru"
                  options "caps:escape,compose:paus"
                }
                track-layout "window"
              }
              mod-key "Super"
              workspace-auto-back-and-forth
              warp-mouse-to-focus mode="center-xy"
              focus-follows-mouse max-scroll-amount="0%"
            }
            layout {
              gaps 2
              center-focused-column "never"
              border { off; }
              focus-ring {
                width 2
                active-color "${base0D}"
                inactive-color "${base03}"
              }
              tab-indicator {
                hide-when-single-tab
                place-within-column
                width 4
              }
            }
            cursor {
              xcursor-size ${builtins.toString config.stylix.cursor.size}
              xcursor-theme "${config.stylix.cursor.name}"
            }
            animations { off; }
            screenshot-path "~/down/screenshot-%Y-%m-%d %H-%M-%S.png"
            binds {
              Mod+Space { switch-layout "next"; }
              Mod+Return { spawn "uwsm" "app" "--" "footclient"; }
              Mod+D { spawn "uwsm" "app" "--" "wofi" "-S" "run"; }
              Mod+Shift+S { spawn "uwsm" "app" "--" "wofi-power-menu"; }

              Mod+Q { close-window; }
              Mod+F { maximize-column; }
              Mod+Shift+F { expand-column-to-available-width; }
              Mod+O { toggle-overview; }
              Mod+T { toggle-column-tabbed-display; }
              Mod+C { center-column; }
              Mod+V { toggle-window-floating; }
              Mod+Grave { switch-focus-between-floating-and-tiling; }

              Mod+H { focus-column-left; }
              Mod+Shift+H { move-column-left; }
              Mod+L { focus-column-right; }
              Mod+Shift+L { move-column-right; }
              Mod+J { focus-window-down; }
              Mod+Shift+J { move-window-down; }
              Mod+K { focus-window-up; }
              Mod+Shift+K { move-window-up; }

              Mod+U { focus-workspace-down; }
              Mod+Shift+U { move-workspace-down; }
              Mod+I { focus-workspace-up; }
              Mod+Shift+I { move-workspace-up; }

              Mod+1 { focus-workspace 1; }
              Mod+Shift+1 { move-column-to-workspace 1; }
              Mod+2 { focus-workspace 2; }
              Mod+Shift+2 { move-column-to-workspace 2; }
              Mod+3 { focus-workspace 3; }
              Mod+Shift+3 { move-column-to-workspace 3; }
              Mod+4 { focus-workspace 4; }
              Mod+Shift+4 { move-column-to-workspace 4; }
              Mod+5 { focus-workspace 5; }
              Mod+Shift+5 { move-column-to-workspace 5; }
              Mod+6 { focus-workspace 6; }
              Mod+Shift+6 { move-column-to-workspace 6; }
              Mod+7 { focus-workspace 7; }
              Mod+Shift+7 { move-column-to-workspace 7; }
              Mod+8 { focus-workspace 8; }
              Mod+Shift+8 { move-column-to-workspace 8; }
              Mod+9 { focus-workspace 9; }
              Mod+Shift+9 { move-column-to-workspace 9; }
              Mod+0 { focus-workspace 10; }
              Mod+Shift+0 { move-column-to-workspace 10; }

              Mod+Comma { consume-or-expel-window-left; }
              Mod+Period { consume-or-expel-window-right; }

              Print { screenshot; }
              Shift+Print { screenshot-window; }
              Ctrl+Print { screenshot-screen; }

              Mod+Minus { set-column-width "-3%"; }
              Mod+Shift+Minus { set-window-height "-3%"; }
              Mod+Equal { set-column-width "+3%"; }
              Mod+Shift+Equal { set-window-height "+3%"; }
              Mod+R { switch-preset-column-width; }
              Mod+Shift+R { reset-window-height; }

              ${cfg.extra-binds}
            }
            hotkey-overlay {
              skip-at-startup
            }
            gestures {
              hot-corners {
                off
              }
            }
          ''
          + cfg.extra-settings;
      };
  };
}
