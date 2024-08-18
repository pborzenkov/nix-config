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
    accounts = {
      email = {
        maildirBasePath = ".local/share/mail";

        accounts.borzenkov_net = {
          realName = "Pavel Borzenkov";
          address = "pavel@borzenkov.net";
          flavor = "fastmail.com";
          primary = true;
          maildir.path = "borzenkov.net";

          mujmap = {
            enable = true;
            settings = {
              auto_create_new_mailboxes = true;
              lowercase = true;
              password_command = ["pass" "show" "misc/fastmail_jmap"];
            };
          };

          notmuch.enable = true;
        };
      };

      calendar = {
        basePath = ".local/share/calendar";

        accounts.calendar_borzenkov_net = {
          primary = true;

          local = {
            type = "filesystem";
            fileExt = ".ics";
            path = "${config.accounts.calendar.basePath}/borzenkov.net";
          };
          remote = {
            type = "caldav";
            url = "https://caldav.fastmail.com/dav/calendars/user/pavel@borzenkov.net/67fd863c-ebc6-4c6a-afcd-0e72126e5116";
            userName = "pavel@borzenkov.net";
            passwordCommand = ["pass" "show" "misc/fastmail"];
          };

          khal = {
            enable = true;
            type = "calendar";
            color = "light red";
          };
          vdirsyncer.enable = true;
        };
      };

      contact = {
        basePath = ".local/share/contacts";

        accounts.contacts_borzenkov_net = {
          local = {
            type = "filesystem";
            fileExt = ".vcf";
            path = "${config.accounts.contact.basePath}/borzenkov.net";
          };
          remote = {
            type = "carddav";
            url = "https://carddav.fastmail.com/dav/addressbooks/user/pavel@borzenkov.net/Default";
            userName = "pavel@borzenkov.net";
            passwordCommand = ["pass" "show" "misc/fastmail"];
          };

          khal = {
            enable = true;
            readOnly = true;
            color = "light blue";
          };
          khard.enable = true;
          vdirsyncer.enable = true;
        };
      };
    };

    home.packages = let
      mailsync = pkgs.writeScriptBin "mailsync" ''
        notmuch tag -inbox -unread -- tag:deleted AND tag:inbox
        mujmap -C ${config.accounts.email.maildirBasePath}/borzenkov.net sync
      '';
    in [
      pkgs.notmuch-bower
      mailsync
    ];

    programs = {
      mujmap.enable = true;
      notmuch = {
        enable = true;
        extraConfig = {
          "bower:addressbook" = {
            meme = "Pavel Borzenkov <pavel@borzenkov.net>";
          };
          "bower:search_alias" = {
            default = "path:borzenkov.net/** AND tag:inbox";
            i = "~default";
          };
          "bower:maildir" = {
            drafts_folder = "drafts";
          };
        };
      };
      khal.enable = true;
      khard.enable = true;
      vdirsyncer = {
        enable = true;
        statusPath = "${config.xdg.stateHome}/vdirsyncer/status";
      };
    };

    xdg.configFile = {
      "bower.conf" = {
        target = "bower/bower.conf";
        text = lib.generators.toINI {} {
          filter = {
            "text/html" = "${pkgs.w3m-batch}/bin/w3m -dump -O UTF-8 -T text/html -o display_link_number=1";
          };
          ui = {
            poll_period_secs = "off";
            default_save_directory = "~/down";
          };
          "account.borzenkov.net" = {
            from_address = "Pavel Borzenkov <pavel@borzenkov.net>";
            default = true;
            sendmail = "mujmap -C ${config.accounts.email.maildirBasePath}/borzenkov.net send";
            post_sendmail = "";
          };
          color = {
            current = "bold black / white";
          };
          "color.status" = {
            bar = "white / default";
            info = "bold green";
            warning = "bold red";
          };
        };
      };
    };
  };
}
