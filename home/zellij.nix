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
          compact-bar { path "compact-bar"; }
          session-manager { path "session-manager"; }
        }

        keybinds clear-defaults=true {
          locked {
            bind "Ctrl 1" { SwitchToMode "Normal"; }
          }
          shared_except "locked" {
            bind "Ctrl 1" { SwitchToMode "Locked"; }
          }

          normal {
            bind "Ctrl '" { SwitchToMode "Scroll"; }
            bind "Ctrl ;" { SwitchToMode "Session"; }
            bind "Ctrl >" { SwitchToMode "Move"; }
            bind "Ctrl <" { SwitchToMode "Resize"; }
            bind "Ctrl ." { SwitchToMode "Pane"; }
            bind "Ctrl ," { SwitchToMode "Tab"; }

            bind "Alt h" { MoveFocus "Left"; }
            bind "Alt l" { MoveFocus "Right"; }
            bind "Alt j" { MoveFocus "Down"; }
            bind "Alt k" { MoveFocus "Up"; }
          }

          scroll {
            bind "Ctrl '" { SwitchToMode "Normal"; }

            bind "e" { EditScrollback; SwitchToMode "Normal"; }
            bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
            bind "j" { ScrollDown; }
            bind "k" { ScrollUp; }
            bind "Ctrl f" { PageScrollDown; }
            bind "Ctrl b" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
          }
          entersearch {
            bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
            bind "Enter" { SwitchToMode "Search"; }
          }
          search {
            bind "Ctrl '" { SwitchToMode "Normal"; }

            bind "e" { EditScrollback; SwitchToMode "Normal"; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
            bind "j" { ScrollDown; }
            bind "k" { ScrollUp; }
            bind "Ctrl f" { PageScrollDown; }
            bind "Ctrl b" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
            bind "n" { Search "down"; }
            bind "p" { Search "up"; }
            bind "c" { SearchToggleOption "CaseSensitivity"; }
            bind "w" { SearchToggleOption "Wrap"; }
            bind "o" { SearchToggleOption "WholeWord"; }
          }

          session {
            bind "Ctrl ;" { SwitchToMode "Normal"; }

            bind "d" { Detach; }
            bind "w" {
              LaunchOrFocusPlugin "zellij:session-manager" {
                floating true
                move_to_focused_tab true
              };
              SwitchToMode "Normal"
            }
          }

          move {
            bind "Ctrl >" { SwitchToMode "Normal"; }

            bind "n" { MovePane; }
            bind "p" { MovePaneBackwards; }
            bind "h" { MovePane "Left"; }
            bind "j" { MovePane "Down"; }
            bind "k" { MovePane "Up"; }
            bind "l" { MovePane "Right"; }
          }

          resize {
            bind "Ctrl <" { SwitchToMode "Normal"; }

            bind "h" { Resize "Increase Left"; }
            bind "j" { Resize "Increase Down"; }
            bind "k" { Resize "Increase Up"; }
            bind "l" { Resize "Increase Right"; }
            bind "H" { Resize "Decrease Left"; }
            bind "J" { Resize "Decrease Down"; }
            bind "K" { Resize "Decrease Up"; }
            bind "L" { Resize "Decrease Right"; }
            bind "=" "+" { Resize "Increase"; }
            bind "-" { Resize "Decrease"; }
          }

          pane {
            bind "Ctrl ." { SwitchToMode "Normal"; }

            bind "h" { MoveFocus "Left"; }
            bind "l" { MoveFocus "Right"; }
            bind "j" { MoveFocus "Down"; }
            bind "k" { MoveFocus "Up"; }
            bind "p" { SwitchFocus; }
            bind "n" { NewPane; SwitchToMode "Normal"; }
            bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
            bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
            bind "x" { CloseFocus; SwitchToMode "Normal"; }
            bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
            bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
            bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
            bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
            bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0;}
          }
          renamepane {
            bind "Ctrl c" { SwitchToMode "Normal"; }
            bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
          }

          tab {
            bind "Ctrl ," { SwitchToMode "Normal"; }

            bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
            bind "h" "Left" "Up" "k" { GoToPreviousTab; }
            bind "l" "Right" "Down" "j" { GoToNextTab; }
            bind "n" { NewTab; SwitchToMode "Normal"; }
            bind "x" { CloseTab; SwitchToMode "Normal"; }
            bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
            bind "b" { BreakPane; SwitchToMode "Normal"; }
            bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
            bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
            bind "1" { GoToTab 1; SwitchToMode "Normal"; }
            bind "2" { GoToTab 2; SwitchToMode "Normal"; }
            bind "3" { GoToTab 3; SwitchToMode "Normal"; }
            bind "4" { GoToTab 4; SwitchToMode "Normal"; }
            bind "5" { GoToTab 5; SwitchToMode "Normal"; }
            bind "6" { GoToTab 6; SwitchToMode "Normal"; }
            bind "7" { GoToTab 7; SwitchToMode "Normal"; }
            bind "8" { GoToTab 8; SwitchToMode "Normal"; }
            bind "9" { GoToTab 9; SwitchToMode "Normal"; }
            bind "Tab" { ToggleTab; }
          }
          renametab {
            bind "Ctrl c" { SwitchToMode "Normal"; }
            bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
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
