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
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        browserpass
        translate-web-pages
        ublock-origin
      ];
    };
  };
}

