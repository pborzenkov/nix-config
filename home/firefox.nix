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

        settings = {
          "browser.download.folderList" = 2;
          "browser.download.dir" = "${config.home.homeDirectory}/down";

          "signon.rememberSignons" = false;
        };
      };
      extensions =
        let
          rycee = pkgs.nur.repos.rycee.firefox-addons;
          pborzenkov = pkgs.nur.repos.pborzenkov.firefox-addons;
        in
        [
          rycee.browserpass
          rycee.translate-web-pages
          rycee.ublock-origin

          pborzenkov.wallabagger
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

