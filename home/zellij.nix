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
        default_mode "locked"
        mouse_mode false
        pane_frames false
        simplified_ui true
        copy_on_select true
        scrollback_editor "${pkgs.helix}/bin/hx"

        plugins {
          tab-bar { path "tab-bar"; }
          status-bar { path "status-bar"; }
          strider { path "strider"; }
          compact-bar { path "compact-bar"; }
        }

        keybinds {
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
