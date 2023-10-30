{
  config,
  lib,
  pkgs,
  ...
}: let
  mailsync = pkgs.writeScriptBin "mailsync" ''
    ${pkgs.notmuch}/bin/notmuch tag -inbox -unread -- tag:deleted AND tag:inbox
    ${pkgs.mujmap}/bin/mujmap -C ${config.accounts.email.maildirBasePath}/borzenkov.net sync
  '';

  vdirsync = pkgs.writeScriptBin "vdirsync" ''
    ${pkgs.vdirsyncer}/bin/vdirsyncer sync
  '';
in {
  accounts = {
    email = {
      maildirBasePath = ".local/share/mail";

      accounts."borzenkov.net" = {
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
            password_command = ["${pkgs.pass}/bin/pass" "show" "misc/fastmail_jmap"];
          };
        };

        notmuch.enable = true;
      };
    };

    calendar = {
      basePath = ".local/share/calendar";

      accounts."borzenkov_net" = {
        primary = true;
        primaryCollection = "borzenkov_net";

        local = {
          type = "filesystem";
          fileExt = ".ics";
          path = "${config.accounts.calendar.basePath}/borzenkov.net";
        };
        remote = {
          type = "caldav";
          url = "https://caldav.fastmail.com/dav/calendars/user/pavel@borzenkov.net/67fd863c-ebc6-4c6a-afcd-0e72126e5116";
          userName = "pavel@borzenkov.net";
          passwordCommand = ["${pkgs.pass}/bin/pass" "show" "misc/fastmail"];
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

      accounts."borzenkov_net" = {
        local = {
          type = "filesystem";
          fileExt = ".vcf";
          path = "${config.accounts.contact.basePath}/borzenkov.net";
        };
        remote = {
          type = "carddav";
          url = "https://carddav.fastmail.com/dav/addressbooks/user/pavel@borzenkov.net/Default/";
          userName = "pavel@borzenkov.net";
          passwordCommand = ["${pkgs.pass}/bin/pass" "show" "misc/fastmail"];
        };

        # khal = {
        #   enable = true;
        #   readOnly = true;
        # };
        khard.enable = true;
        vdirsyncer.enable = true;
      };
    };
  };

  home.packages = [
    pkgs.notmuch-bower
    mailsync
    vdirsync
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
    # khal.enable = true;
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
}
