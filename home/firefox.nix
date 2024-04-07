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
        nativeMessagingHosts = [
          pkgs.tridactyl-native
        ];
      };
      profiles.default = {
        id = 0;
        isDefault = true;
        name = "default";
        search = {
          force = true;
          default = "DuckDuckGo";
        };

        settings = {
          "browser.download.folderList" = 2;
          "browser.download.dir" = "${config.home.homeDirectory}/down";
          "browser.startup.page" = 3;
          "browser.warnOnQuitShortcut" = false;

          "signon.rememberSignons" = false;
        };

        extensions = let
          rycee = pkgs.nur.repos.rycee.firefox-addons;
          pborzenkov = pkgs.nur.repos.pborzenkov.firefox-addons;
        in [
          rycee.browserpass
          rycee.tridactyl
          rycee.ublock-origin
          rycee.istilldontcareaboutcookies

          pborzenkov.shiori_ext
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
          blacklistadd https://app.fastmail.com

          bind J tabnext
          bind K tabprev
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
