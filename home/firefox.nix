{ config, pkgs, ... }:

{
  programs = {
    browserpass = {
      enable = true;
      browsers = [ "firefox" ];
    };

    firefox = {
      enable = true;
      profiles.default = {
        id = 0;
        isDefault = true;
        name = "default";
      };
      extensions = [
        pkgs.nur.repos.rycee.firefox-addons.browserpass
        pkgs.nur.repos.rycee.firefox-addons.translate-web-pages
        pkgs.nur.repos.rycee.firefox-addons.ublock-origin

        pkgs.nur.repos.pborzenkov.firefox-addons.wallabagger
      ];
    };
  };
}

