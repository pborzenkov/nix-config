{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.wm;

  scratch-term =
    let
      config = pkgs.writeTextFile {
        name = "scratch-term-zellij-config";
        text = ''
          on_force_close "detach"
          simplified_ui true
          pane_frames false
          default_shell "fish"
          theme "default"
          default_mode "locked"
          mouse_mode false
          copy_command "wl-copy"
          scrollback_editor "hx"
          session_serialization false
          show_startup_tips false
          show_release_notes false

          keybinds clear-defaults=true {
            locked {
              bind "Ctrl t" { "NewTab"; }

              bind "Alt 1" { GoToTab 1; }
              bind "Alt 2" { GoToTab 2; }
              bind "Alt 3" { GoToTab 3; }
              bind "Alt 4" { GoToTab 4; }
              bind "Alt 5" { GoToTab 5; }
              bind "Alt 6" { GoToTab 6; }
              bind "Alt 7" { GoToTab 7; }
              bind "Alt 8" { GoToTab 8; }
              bind "Alt 9" { GoToTab 9; }
              bind "Alt 0" { GoToTab 10; }

              bind "Ctrl Shift f" { PageScrollDown; }
              bind "Ctrl Shift d" { HalfPageScrollDown; }
              bind "Ctrl Shift j" { ScrollDown; }
              bind "Ctrl Shift e" { ScrollToBottom; }
              bind "Ctrl Shift b" { PageScrollUp; }
              bind "Ctrl Shift u" { HalfPageScrollUp; }
              bind "Ctrl Shift k" { ScrollUp; }

              bind "Alt r" { SwitchToMode "renametab"; }
            }
            renametab {
              bind "Enter" { SwitchToMode "locked"; }
              bind "Esc" { UndoRenameTab; SwitchToMode "locked"; }
            }
          }
        '';
      };
      layout = pkgs.writeTextFile {
        name = "scratch-term-zellij-layout";
        text = ''
          layout {
            pane size=1 borderless=true {
              plugin location="tab-bar"
            }
            pane
          }
        '';
      };
    in
    pkgs.writeShellApplication {
      name = "scratch-term";
      text = ''
        zellij --config ${config} --layout ${layout} attach --create scratch-term
      '';
    };
in
{
  imports = pborlib.allDirs ./.;

  options = {
    pbor.wm.enable = (lib.mkEnableOption "Enable WM") // {
      default = config.pbor.enable && isDesktop;
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        };
      };
    };

    hm =
      { config, ... }:
      {
        home.packages = with pkgs; [
          wev
          wl-clipboard
          xdg-utils
          scratch-term
        ];
        programs.zellij.enable = true;
        stylix.targets.zellij.enable = true;

        xdg.configFile."uwsm/env".text = ''
          export MOZ_ENABLE_WAYLAND=1
          export QT_QPA_PLATFORM=wayland
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export NIXOS_OZONE_WL=1
          export SDL_VIDEODRIVER=wayland,x11
          export PROTON_ENABLE_WAYLAND=1
          export PROTON_ENABLE_HDR=1
          export GRIM_DEFAULT_DIR="${config.home.homeDirectory}/down"
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent";
          export PATH="$PATH:$HOME/bin"
        '';
      };
  };
}
