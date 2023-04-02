{
  config,
  lib,
  pkgs,
  ...
}: {
  accounts.email = {
    maildirBasePath = ".local/share/mail";

    accounts = {
      "borzenkov.net" = {
        realName = "Pavel Borzenkov";
        address = "pavel@borzenkov.net";
        flavor = "fastmail.com";
        primary = true;
        maildir.path = "borzenkov.net";

        userName = "pavel@borzenkov.net";

        mujmap = {
          enable = true;
          settings = {
            auto_create_new_mailboxes = true;
            lowercase = true;
            password_command = ["${pkgs.pass}/bin/pass" "show" "misc/fastmail_jmap"];
          };
        };

        notmuch.enable = true;
      };
    };
  };

  home.packages = [
    pkgs.notmuch-bower
    pkgs.vdirsyncer
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
  };

  xdg.configFile = {
    "bower.conf" = {
      target = "bower/bower.conf";
      text = lib.generators.toINI {} {
        command = {
          editor = "${pkgs.helix}/bin/hx";
        };
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
          sendmail = "${pkgs.mujmap}/bin/mujmap -C ${config.accounts.email.maildirBasePath}/borzenkov.net send";
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

  xdg.configFile.vdirsyncer = {
    text =
      lib.generators.toINI {
        mkKeyValue = lib.generators.mkKeyValueDefault {
          mkValueString = builtins.toJSON;
        } "=";
      } {
        general = {
          status_path = "${config.xdg.stateHome}/vdirsyncer/borzenkov.net";
        };

        "pair borzenkov_net_contacts" = {
          a = "borzenkov_net_contacts_local";
          b = "borzenkov_net_contacts_remote";
          collections = ["from a" "from b"];
        };

        "storage borzenkov_net_contacts_local" = {
          type = "filesystem";
          path = "${config.xdg.dataHome}/contacts/borzenkov.net";
          fileext = ".vcf";
        };

        "storage borzenkov_net_contacts_remote" = {
          type = "carddav";
          url = "https://carddav.fastmail.com/";
          username = "pavel@borzenkov.net";
          "password.fetch" = ["command" "${pkgs.pass}/bin/pass" "show" "misc/fastmail"];
        };

        "pair borzenkov_net_calendar" = {
          a = "borzenkov_net_calendar_local";
          b = "borzenkov_net_calendar_remote";
          collections = ["from a" "from b"];
        };

        "storage borzenkov_net_calendar_local" = {
          type = "filesystem";
          path = "${config.xdg.dataHome}/calendar/borzenkov.net";
          fileext = ".ics";
        };

        "storage borzenkov_net_calendar_remote" = {
          type = "caldav";
          url = "https://caldav.fastmail.com/";
          username = "pavel@borzenkov.net";
          "password.fetch" = ["command" "${pkgs.pass}/bin/pass" "show" "misc/fastmail"];
        };
      };
    target = "vdirsyncer/borzenkov.net";
  };
}
