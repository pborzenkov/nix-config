{
  config,
  inputs,
  pkgs,
  ...
}: {
  programs = {
    browserpass = {
      enable = true;
      browsers = ["firefox"];
    };

    firefox = {
      enable = pkgs.stdenv.isLinux;
      package = pkgs.firefox.override {
        cfg = {
          enableTridactylNative = true;
        };
      };
      profiles.default = {
        id = 0;
        isDefault = true;
        name = "default";

        settings = {
          "browser.download.folderList" = 2;
          "browser.download.dir" = "${config.home.homeDirectory}/down";
          "browser.startup.page" = 3;

          "signon.rememberSignons" = false;
        };

        extensions = let
          rycee = pkgs.nur.repos.rycee.firefox-addons;
          pborzenkov = pkgs.nur.repos.pborzenkov.firefox-addons;
        in [
          rycee.browserpass
          rycee.translate-web-pages
          rycee.tridactyl
          rycee.ublock-origin

          pborzenkov.wallabagger
        ];
      };
    };
  };

  home.file.urlview = {
    target = ".urlview";
    text = ''
      COMMAND ${
        if pkgs.stdenv.isDarwin
        then "/usr/bin/open"
        else "${pkgs.xdg-utils}/bin/xdg-open"
      }
    '';
  };

  xdg = {
    configFile = {
      tridactyl = {
        target = "tridactyl/tridactylrc";
        text = ''
          colourscheme base16

          blacklistadd https://rss.lab.borzenkov.net
        '';
      };
      tridactyl-base16 = {
        target = "tridactyl/themes/base16.css";
        text = builtins.readFile "${inputs.base16-tridactyl}/base16-${config.scheme.slug}.css";
      };
    };
    mimeApps = {
      defaultApplications = {
        "text/html" = ["firefox.desktop"];
      };
    };
  };
}
