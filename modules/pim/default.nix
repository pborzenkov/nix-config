{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.pim;
in {
  options = {
    pbor.pim.enable = (lib.mkEnableOption "Enable PIM") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    hm = {config, ...}: {
      programs = {
        aerc = {
          enable = true;
          package = pkgs.unstable.aerc;
          extraAccounts."pavel@borzenkov.net" = {
            source = "jmap+oauthbearer://api.fastmail.com/jmap/session";
            source-cred-cmd = "rbw get fastmail.com/jmap";
            outgoing = "jmap://";
            from = "Pavel Borzenkov <pavel@borzenkov.net>";
            default = "Inbox";
            folders-sort = "Inbox,nixos,rust-users,Sent";
            cache-state = true;
            cache-blobs = true;
            use-labels = true;

            carddav-source = "https://pavel@borzenkov.net@carddav.fastmail.com/dav/addressbooks/user/pavel@borzenkov.net/Default";
            carddav-source-cred-cmd = "rbw get fastmail.com/desktop";
            address-book-cmd = "carddav-query -S pavel@borzenkov.net %s";
          };
          extraConfig = {
            general = {
              unsafe-accounts-conf = true;
              default-save-path = "${config.xdg.userDirs.download}";
              term = "foot";
              enable-osc8 = true;
            };
            ui = {
              new-message-bell = false;
              threading-enabled = true;
              auto-mark-read = true;
              completion-min-chars = "manual";
              styleset-name = "base16";
            };
            viewer = {
              pager = "less -Rc";
              header-layout = "From,To,Cc,Bcc,Date,Subject";
            };
            compose = {
              editor = "hx";
              header-layout = "To,From,Subject";
              reply-to-self = false;
              empty-subject-warning = true;
              no-attachment-warnings = "^[^>]*attach(ed|ment)";
            };
            filters = {
              "text/plain" = "wrap -w 100 | colorize";
              "text/html" = "html | colorize";
              "text/calendar" = "calendar";
            };
          };
          extraBinds = {
            global = {
              "<C-l>" = ":next-tab<Enter>";
              "<C-h>" = ":prev-tab<Enter>";
              "<C-t>" = ":term<Enter>";
              "?" = ":help keys<Enter>";
            };

            messages = {
              "O" = ":check-mail<Enter>";
              "q" = ":quit<Enter>";

              "j" = ":next<Enter>";
              "<C-d>" = ":next 50%<Enter>";
              "<C-f>" = ":next 100%<Enter>";
              "J" = ":next-folder<Enter>";
              "L" = ":expand-folder<Enter>";

              "k" = ":prev<Enter>";
              "<C-u>" = ":prev 50%<Enter>";
              "<C-b>" = ":prev 100%<Enter>";
              "K" = ":prev-folder<Enter>";
              "H" = ":collapse-folder<Enter>";

              "g" = ":select 0<Enter>";
              "G" = ":select -1<Enter>";

              "v" = ":mark -t<Enter>";
              "<Space>" = ":mark -t<Enter>:next<Enter>";
              "V" = ":mark -v<Enter>";

              "T" = ":toggle-threads<Enter>";
              "zc" = ":fold<Enter>";
              "zo" = ":unfold<Enter>";

              "zz" = ":align center<Enter>";
              "zt" = ":align top<Enter>";
              "zb" = ":align bottom<Enter>";

              "<Enter>" = ":view<Enter>";
              "u" = ":read -t<Enter>";
              "C" = ":compose<Enter>";
              "d" = ":delete<Enter>";
              "a" = ":archive flat<Enter>";
              "m" = ":move<space>";
              "A" = ":unmark -a<Enter>:mark -T<Enter>:archive flat<Enter>";
              "b" = ":bounce<Enter>";
              "rr" = ":reply -a<Enter>";
              "rq" = ":reply -aq<Enter>";
              "Rr" = ":reply<Enter>";
              "Rq" = ":reply -q<Enter>";

              "c" = ":cf<space>";
              "!" = ":term<space>";
              "|" = ":pipe<space>";

              "/" = ":search<space>";
              "\\" = ":filter<space>";
              "n" = ":next-result<Enter>";
              "N" = ":prev-result<Enter>";
              "<Esc>" = ":clear<Enter>";

              "s" = ":split<Enter>";
              "S" = ":vsplit<Enter>";
            };

            "messages:folder=Drafts" = {
              "<Enter>" = ":recall<Enter>";
            };

            view = {
              "/" = ":toggle-key-passthrough<Enter>/";
              "q" = ":close<Enter>";
              "o" = ":open<Enter>";
              "s" = ":save<space>";
              "|" = ":pipe<space>";
              "d" = ":delete<enter>";
              "a" = ":archive flat<enter>";

              "<C-o>" = ":open-link <space>";

              "f" = ":forward<Enter>";
              "rr" = ":reply -a<Enter>";
              "rq" = ":reply -aq<Enter>";
              "Rr" = ":reply<Enter>";
              "Rq" = ":reply -q<Enter>";

              "H" = ":toggle-headers<Enter>";
              "J" = ":next<Enter>";
              "<C-j>" = ":next-part<Enter>";
              "K" = ":prev<Enter>";
              "<C-k>" = ":prev-part<Enter>";
            };

            "view::passthrough" = {
              "$noinherit" = true;
              "$ex" = "<C-x>";
              "<Esc>" = ":toggle-key-passthrough<Enter>";
            };

            "compose" = {
              "$noinherit" = true;
              "$ex" = "<C-x>";
              "$complete" = "<Tab>";

              "<C-j>" = ":next-field<Enter>";
              "<C-l>" = ":next-tab<Enter>";
              "<A-n>" = ":switch-account -n<Enter>";
              "<C-k>" = ":prev-field<Enter>";
              "<C-h>" = ":prev-tab<Enter>";
              "<A-p>" = ":switch-account -p<Enter>";
            };

            "compose::editor" = {
              "$noinherit" = true;
              "$ex" = "<C-x>";

              "<C-j>" = ":next-field<Enter>";
              "<C-l>" = ":next-tab<Enter>";
              "<C-k>" = ":prev-field<Enter>";
              "<C-h>" = ":prev-tab<Enter>";
            };

            "compose::review" = {
              "y" = ":send<Enter>";
              "n" = ":abort<Enter>";
              "v" = ":preview<Enter>";
              "p" = ":postpone<Enter>";
              "q" = ":choose -o d discard abort -o p postpone postpone<Enter>";
              "e" = ":edit<Enter>";
              "a" = ":attach<space>";
              "d" = ":detach<space>";
              "c" = ":cc<space> # Add Cc";
              "b" = ":bcc<space> # Add Bcc";
            };

            "terminal" = {
              "$noinherit" = true;
              "$ex" = "<C-x>";

              "<C-l>" = ":next-tab<Enter>";
              "<C-h>" = ":prev-tab<Enter>";
            };
          };
        };
      };

      xdg.configFile."aerc/stylesets/base16".text = with config.lib.stylix.colors.withHashtag; ''
        #
        # aerc base16 styleset template by h4n1

        *.default=true
        *.selected.reverse=true
        *.bg="${base00}"

        title.bold=true
        header.italic=true

        *error.bold=true
        error.fg="${base08}"
        warning.fg="${base09}"
        success.fg="${base0B}"

        statusline_default.reverse=false
        statusline*.bg="${base01}"
        statusline_default.fg="${base04}"
        statusline_error.fg="${base08}"
        statusline_error.reverse=true

        msglist_unread.bold=true
        msglist_unread.fg="${base06}"
        msglist_deleted.fg="${base03}"
        msglist_marked.bg="${base02}"
        msglist_flagged.fg="${base0A}"

        dirlist*.fg="${base04}"
        dirlist_unread.fg="${base05}"
        dirlist*.bg="${base00}"
        dirlist*.selected.bg="${base02}"
        dirlist*.selected.fg="${base05}"
        dirlist*.selected.bold=true
        dirlist_recent.italic=true

        completion*.selected.reverse=true
        completion*.selected.bold=true
        completion*.bg="${base01}"
        completion*.fg="${base05}"

        tab.reverse=false
        tab.bg="${base00}"
        tab.fg="${base04}"

        border.bg="${base00}"
        border.fg="${base01}"
        spinner.fg="${base03}"

        selector_focused.reverse=true
        selector_chooser.bold=true
      '';
    };
  };
}
