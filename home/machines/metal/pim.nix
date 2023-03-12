{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  accounts.email = {
    maildirBasePath = ".local/share/mail";

    accounts = {
      "borzenkov.net" = {
        realName = "Pavel Borzenkov";
        address = "pavel@borzenkov.net";
        primary = true;
        maildir.path = "borzenkov.net";
        jmap = {
          host = "fastmail.com";
          sessionUrl = "https://jmap.fastmail.com/.well-known/jmap";
        };

        userName = "pavel@borzenkov.net";
        passwordCommand = ["${pkgs.coreutils}/bin/cat" "/var/run/secrets/fastmail"];

        aerc = {
          enable = true;
          extraAccounts = let
            query-map = pkgs.writeText "borzenkov.net-query-map" ''
              inbox=tag:inbox and folder:borzenkov.net
              nixos=tag:nixos and folder:borzenkov.net
              rust-users=tag:rust-users and folder:borzenkov.net
              sent=tag:sent and folder:borzenkov.net
            '';
          in {
            check-mail-cmd = "${pkgs.mujmap}/bin/mujmap -C ${config.accounts.email.maildirBasePath}/borzenkov.net sync";
            check-mail-timeout = "60s";
            outgoing = "${pkgs.mujmap}/bin/mujmap -C ${config.accounts.email.maildirBasePath}/borzenkov.net send";
            source = "notmuch://${config.accounts.email.maildirBasePath}";
            query-map = "${query-map}";
            folders-sort = "inbox,nixos,rust-users";
            exclude-tags = "deleted,spam";

            default = "";
            copy-to = "";
            postpone = "";

            from = "Pavel Borzenkov <pavel@borzenkov.net>";
          };
        };

        mujmap = {
          enable = true;
          settings = {
            auto_create_new_mailboxes = true;
            lowercase = true;
            password_command = ["${pkgs.coreutils}/bin/cat" "/var/run/secrets/fastmail_jmap"];
          };
        };

        notmuch.enable = true;
      };
    };
  };

  home.packages = [pkgs.notmuch-bower];

  programs = {
    aerc = {
      enable = true;
      extraConfig = {
        compose = {
          editor = "${pkgs.helix}/bin/hx";
        };
        filters = {
          "text/plain" = "wrap -w 100 | colorize";
          "text/html" = "${pkgs.w3m}/bin/w3m -T text/html -cols $(${pkgs.ncurses}/bin/tput cols) -dump -o display_image=false -o display_link_number=true";
          "text/calendar" = "calendar";
        };
        general = {
          unsafe-accounts-conf = true;
        };
        viewer = {
          pager = "${pkgs.bat}/bin/bat --style=plain";
        };
        ui = {
          styleset-name = "base16";
          threading-enabled = false;
          sort = "-r date";
        };
      };
      extraBinds = {
        global = {
          "<C-p>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
          "<C-t>" = ":term<Enter>";
          "?" = ":keys<Enter>";
        };

        messages = {
          q = ":quit<Enter>";

          j = ":next<Enter>";
          "<C-d>" = ":next 50%<Enter>";
          "<C-f>" = ":next 100%<Enter>";

          k = ":prev<Enter>";
          "<C-u>" = ":prev 50%<Enter>";
          "<C-b>" = ":prev 100%<Enter>";

          g = ":select 0<Enter>";
          G = ":select -1<Enter>";
          m = ":mark -t<Enter>:next<Enter>";
          "<Enter>" = ":view<Enter>";

          d = ":tag -inbox +deleted<Enter>:next<Enter>";
          a = ":tag -inbox<Enter>:next<Enter>";
          u = ":read -t<Enter>:next<Enter>";

          J = ":next-folder<Enter>";
          K = ":prev-folder<Enter>";

          T = ":toggle-threads<Enter>";

          S = ":check-mail<Enter>";
          C = ":compose<Enter>";
          rr = ":reply -aq<Enter>";
          rq = ":reply -a<Enter>";
          Rr = ":reply -q<Enter>";
          Rq = ":reply<Enter>";

          c = ":cf<space>";

          "/" = ":filter<space>";
          "<Esc>" = ":clear<Enter>";
        };

        view = {
          "/" = ":toggle-key-passthrough<Enter>/";
          q = ":close<Enter>";
          o = ":open<Enter>";
          s = ":save<space>";
          "|" = ":pipe<space>";
          d = ":tag -inbox +deleted<Enter>:close<Enter>";
          a = ":tag -inbox<Enter>:close<Enter>";

          "<C-l>" = ":open-link<space>";

          f = ":forward<Enter>";
          rr = ":reply -aq<Enter>";
          rq = ":reply -a<Enter>";
          Rr = ":reply -q<Enter>";
          Rq = ":reply<Enter>";

          H = ":toggle-headers<Enter>";
          "<C-k>" = ":prev-part<Enter>";
          "<C-j>" = ":next-part<Enter>";
          J = ":next<Enter>";
          K = ":prev<Enter>";
        };

        "view::passthrough" = {
          "$noinherit" = true;
          "$ex" = "<C-x>";
          "<Esc>" = ":toggle-key-passthrough<Enter>";
        };

        compose = {
          "$noinherit" = true;
          "$ex" = "<C-x>";
          "<C-k>" = ":prev-field<Enter>";
          "<C-j>" = ":next-field<Enter>";
        };

        "compose::editor" = {
          "$noinherit" = true;
          "$ex" = "<C-x>";
          "<C-k>" = ":prev-field<Enter>";
          "<C-j>" = ":next-field<Enter>";
        };

        "compose::review" = {
          y = ":send<Enter>";
          n = ":abort<Enter>";
          v = ":preview<Enter>";
          e = ":edit<Enter>";
          a = ":attach<space>";
          d = ":detach<space>";
        };

        terminal = {
          "$noinherit" = true;
          "$ex" = "<C-x>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
        };
      };
      stylesets.base16 = builtins.readFile (config.scheme {
        templateRepo = inputs.base16-aerc;
        extension = "";
      });
    };
    mujmap.enable = true;
    notmuch.enable = true;
  };

  xdg.configFile.vdirsyncer = {
    text = ''
      [general]
      status_path = "~/.local/state/vdirsyncer/borzenkov.net"

      [pair borzenkov_net_contacts]
      a = "borzenkov_net_contacts_local"
      b = "borzenkov_net_contacts_remote"
      collections = ["from a", "from b"]

      [storage borzenkov_net_contacts_local]
      type = "filesystem"
      path = "~/.local/share/contacts/borzenkov.net"
      fileext = ".vcf"

      [storage borzenkov_net_contacts_remote]
      type = "carddav"
      url = "https://carddav.fastmail.com/"
      username = "pavel@borzenkov.net"
      password.fetch = ["command", "${pkgs.coreutils}/bin/cat", "/var/run/secrets/fastmail"]

      [pair borzenkov_net_calendar]
      a = "borzenkov_net_calendar_local"
      b = "borzenkov_net_calendar_remote"
      collections = ["from a", "from b"]

      [storage borzenkov_net_calendar_local]
      type = "filesystem"
      path = "~/.local/share/calendar/borzenkov.net"
      fileext = ".ics"

      [storage borzenkov_net_calendar_remote]
      type = "caldav"
      url = "https://caldav.fastmail.com/"
      username = "pavel@borzenkov.net"
      password.fetch = ["command", "${pkgs.coreutils}/bin/cat", "/var/run/secrets/fastmail"]
    '';
    target = "vdirsyncer/config";
  };

  systemd.user = {
    services.vdirsyncer = let
      vdirsyncerDiscover = pkgs.writeShellScript "vdirsyncer-discover" ''
        ${pkgs.coreutils}/bin/yes | ${pkgs.vdirsyncer}/bin/vdirsyncer discover
      '';
    in {
      Unit = {
        Description = "synchronize calendars and contacts";
      };
      Service = {
        Type = "oneshot";
        ExecStart = ["${vdirsyncerDiscover}" "${pkgs.vdirsyncer}/bin/vdirsyncer sync"];
      };
    };
    timers.vdirsyncer = {
      Unit = {
        Description = "synchronize calendars and contacts";
      };
      Timer = {
        OnCalendar = "*:0/10";
        Unit = "vdirsyncer.service";
      };
      Install = {
        WantedBy = ["timers.target"];
      };
    };
  };
}
