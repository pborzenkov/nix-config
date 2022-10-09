{ config, pkgs, ... }:

{
  programs = {
    browserpass = {
      enable = true;
      browsers = [ "firefox" ];
    };

    firefox = {
      enable = pkgs.stdenv.isLinux;
      profiles.default = {
        id = 0;
        isDefault = true;
        name = "default";

        settings = { };
      };
      extensions = [
        pkgs.nur.repos.rycee.firefox-addons.browserpass
        pkgs.nur.repos.rycee.firefox-addons.translate-web-pages
        pkgs.nur.repos.rycee.firefox-addons.ublock-origin

        pkgs.nur.repos.pborzenkov.firefox-addons.wallabagger
      ];
    };
  };

  home.file.urlview = {
    target = ".urlview";
    text = ''
      COMMAND ${if pkgs.stdenv.isDarwin then "/usr/bin/open" else "${pkgs.xdg-utils}/bin/xdg-open"}
    '';
  };

  xdg.mimeApps = {
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
    };
  };
}

