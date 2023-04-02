{
  config,
  pkgs,
  ...
}: let
  mailsync = pkgs.writeScriptBin "mailsync" ''
    ${pkgs.notmuch}/bin/notmuch tag -inbox -unread -- tag:deleted AND tag:inbox
    ${pkgs.mujmap}/bin/mujmap -C ${config.accounts.email.maildirBasePath}/borzenkov.net sync
  '';

  vdirsync = pkgs.writeScriptBin "vdirsync" ''
    ${pkgs.coreutils}/bin/yes | ${pkgs.vdirsyncer}/bin/vdirsyncer -c ${config.xdg.configHome}/vdirsyncer/borzenkov.net discover
    ${pkgs.vdirsyncer}/bin/vdirsyncer -c ${config.xdg.configHome}/vdirsyncer/borzenkov.net sync
  '';
in {
  home.packages = [
    mailsync
    vdirsync
  ];
}
