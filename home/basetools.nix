{ config, pkgs, ... }:
let
  theme = config.themes.base16.scheme;
in
{
  programs = {
    bat = {
      enable = true;
      config = {
        theme = theme;
      };
    };

    password-store.enable = true;

    skim = {
      enable = true;
      enableZshIntegration = true;

      defaultCommand = "fd --type f";
      fileWidgetCommand = "fd --type f";
    };
  };

  home.packages = [
    # Search
    pkgs.fd
    pkgs.ripgrep

    # Network
    pkgs.xh
    pkgs.jq
    pkgs.gron

    # Viewers
    pkgs.glow

    # Misc
    pkgs.envsubst
    pkgs.unzip
    pkgs.nur.repos.pborzenkov.osccopy

    # Backups
    pkgs.restic

    # Secrets
    pkgs.sops
  ];

  xdg.configFile = {
    "bat-theme-${theme}" = {
      source = config.lib.base16.base16template "textmate";
      target = "bat/themes/${theme}.tmTheme";
    };

    ripgreprc = {
      target = "ripgreprc";
      text = ''
        --smart-case
      '';
    };
  };

  home.sessionVariables = {
    RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/${config.xdg.configFile.ripgreprc.target}";

    RESTIC_REPOSITORY = "sftp:zh1012@zh1012.rsync.net:restic";
    RESTIC_PASSWORD_COMMAND = "${pkgs.pass}/bin/pass misc/restic@rsync.net";
  };
}
