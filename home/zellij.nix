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
        mouse_mode false
        pane_frames true
        simplified_ui false

        keybinds clear-defaults=true {
          normal {
            bind "Alt d" { Detach; }
            bind "Alt q" { Quit; }

            bind "Alt n" { NewTab; }
            bind "Alt 1" { GoToTab 1; }
            bind "Alt 2" { GoToTab 2; }
            bind "Alt 3" { GoToTab 3; }
            bind "Alt 4" { GoToTab 4; }
            bind "Alt 5" { GoToTab 5; }
            bind "Alt 6" { GoToTab 6; }
            bind "Alt 7" { GoToTab 7; }
            bind "Alt 8" { GoToTab 8; }
            bind "Alt 9" { GoToTab 9; }

            bind "Alt h" { MoveFocus "Left"; }
            bind "Alt j" { MoveFocus "Down"; }
            bind "Alt k" { MoveFocus "Up"; }
            bind "Alt l" { MoveFocus "Right"; }

            bind "Alt H" { Resize "Increase Left"; }
            bind "Alt J" { Resize "Increase Down"; }
            bind "Alt K" { Resize "Increase Up"; }
            bind "Alt L" { Resize "Increase Right"; }

            bind "Alt <" { MovePane "Left"; }
            bind "Alt >" { MovePane "Right"; }
            bind "Alt /" { MovePane "Up"; }
            bind "Alt ?" { MovePane "Down"; }

            bind "Alt v" { NewPane "Right"; }
            bind "Alt b" { NewPane "Down"; }

            bind "Alt f" { ToggleFocusFullscreen; }
            bind "Alt -" { PreviousSwapLayout; }
            bind "Alt =" { NextSwapLayout; }

            bind "Alt [" { SwitchToMode "Scroll"; }
          }

          shared_among "normal" "scroll" "search" {
            bind "Alt E" { EditScrollback; ScrollToBottom; SwitchToMode "Normal"; }
          }

          shared_among "scroll" "search" {
            bind "j" { ScrollDown; }
            bind "Ctrl e" { ScrollDown; }
            bind "Ctrl d" { HalfPageScrollDown; }
            bind "Ctrl f" { PageScrollDown; }
            bind "k" { ScrollUp; }
            bind "Ctrl y" { ScrollUp; }
            bind "Ctrl u" { HalfPageScrollUp; }
            bind "Ctrl b" { PageScrollUp; }

            bind "q" { ScrollToBottom; SwitchToMode "Normal"; }

            bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
          }

          search {
            bind "n" { Search "down"; }
            bind "N" { Search "up"; }
            bind "Alt c" { SearchToggleOption "CaseSensitivity"; }
            bind "Alt w" { SearchToggleOption "Wrap"; }
            bind "Alt o" { SearchToggleOption "WholeWord"; }
            bind "y" { Copy; ScrollToBottom; SwitchToMode "Normal"; }
          }

          entersearch {
            bind "Ctrl c" { SwitchToMode "Scroll"; }
            bind "Enter" { SwitchToMode "Search"; }
          }
        }

        plugins {
          tab-bar { path "tab-bar"; }
          status-bar { path "status-bar"; }
          strider { path "strider"; }
          compact-bar { path "compact-bar"; }
          z-tab-bar { path "${pkgs.z-tab-bar}/lib/z-tab-bar"; }
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

    zellij-z-tab-bar-layout = {
      target = "zellij/layouts/z-tab-bar.kdl";
      text = ''
        layout {
          pane
          pane size=1 borderless=true {
            plugin location="zellij:z-tab-bar"
          }
        }
      '';
    };
  };
}
