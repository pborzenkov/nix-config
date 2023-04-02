{
  config,
  pkgs,
  ...
}: let
  mailsync = pkgs.writeScriptBin "mailsync" ''
    ${pkgs.notmuch}/bin/notmuch tag -inbox -unread -- tag:deleted AND tag:inbox
    ${pkgs.mujmap}/bin/mujmap -C ${config.accounts.email.maildirBasePath}/borzenkov.net sync
    ${pkgs.lieer}/bin/gmi sync -C ${config.accounts.email.maildirBasePath}/fly.io
  '';

  vdirsync = pkgs.writeScriptBin "vdirsync" ''
    ${pkgs.coreutils}/bin/yes | ${pkgs.vdirsyncer}/bin/vdirsyncer -c ${config.xdg.configHome}/vdirsyncer/borzenkov.net discover
    ${pkgs.vdirsyncer}/bin/vdirsyncer -c ${config.xdg.configHome}/vdirsyncer/borzenkov.net sync
  '';
in {
  accounts.email = {
    accounts = {
      "fly.io" = {
        realName = "Pavel Borzenkov";
        address = "pavel@fly.io";
        flavor = "gmail.com";
        maildir.path = "fly.io";

        lieer = {
          enable = true;
          settings = {
            local_trash_tag = "deleted";
          };
        };

        notmuch.enable = true;
      };
    };
  };

  home.packages = [
    mailsync
    vdirsync
  ];

  programs = {
    lieer.enable = true;
    notmuch = {
      extraConfig = {
        "bower:addressbook" = {
          flyme = "Pavel Borzenkov <pavel@fly.io>";
        };
        "bower:search_alias" = {
          flyio = "path:fly.io/** AND tag:inbox";
          w = "~flyio";
        };
      };
    };
  };

  xdg.configFile."bower.conf".text = ''
    [account.fly.io]
    from_address=Pavel Borzenkov <pavel@fly.io>
    sendmail=${pkgs.lieer}/bin/gmi send -C ${config.accounts.email.maildirBasePath}/fly.io
    post_sendmail=
  '';
}
