{
  config,
  pkgs,
  ...
}: {
  programs.zellij = {
    enable = true;
  };

  xdg.configFile = {
    zellij = {
      target = "zellij/config.kdl";
      text = with config.scheme.withHashtag; ''
        default_layout "compact"
        default_mode "normal"
        mouse_mode false
        pane_frames false
        simplified_ui true
        copy_on_select true
        scrollback_editor "${pkgs.helix}/bin/hx"
        session_serialization false

        plugins {
          tab-bar { path "tab-bar"; }
          status-bar { path "status-bar"; }
          strider { path "strider"; }
          compact-bar { path "compact-bar"; }
        }

        keybinds {
          shared {
            unbind "Ctrl h"
            unbind "Ctrl n"
            unbind "Ctrl p"
            unbind "Ctrl t"
            unbind "Ctrl o"
          }
          shared_except "scroll" "search" {
            unbind "Ctrl b"
          }
          shared_except "move" "locked" {
            bind "Ctrl ;" { SwitchToMode "Move"; }
          }
          shared_except "resize" "locked" {
            bind "Ctrl '" { SwitchToMode "Resize"; }
          }
          shared_except "pane" "locked" {
            bind "Ctrl ." { SwitchToMode "Pane"; }
          }
          shared_except "tab" "locked" {
            bind "Ctrl ," { SwitchToMode "Tab"; }
          }
          shared_except "session" "locked" {
            bind "Ctrl 9" { SwitchToMode "Session"; }
          }
          move {
            bind "Ctrl ;" { SwitchToMode "Normal"; }
          }
          resize {
            bind "Ctrl '" { SwitchToMode "Normal"; }
          }
          pane {
            bind "Ctrl ." { SwitchToMode "Normal"; }
          }
          tab {
            bind "Ctrl ," { SwitchToMode "Normal"; }
          }
          session {
            bind "Ctrl 9" { SwitchToMode "Normal"; }
          }
          search {
            bind "e" { EditScrollback; SwitchToMode "Normal"; }
          }
        }

        theme "base16"
        themes {
          base16 {
            fg "${base04}"
            bg "${base00}"
            black "${base01}"
            red "${base0B}"
            green "${base0E}"
            yellow "${base0D}"
            blue "${base09}"
            magenta "${base0F}"
            cyan "${base08}"
            white "${base05}"
            orange "${base0C}"
          }
        }
      '';
    };
  };
}
