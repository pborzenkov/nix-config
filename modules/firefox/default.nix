{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  username,
  ...
}: let
  cfg = config.pbor.firefox;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.firefox.enable = (lib.mkEnableOption "Enable firefox") // {default = config.pbor.enable && isDesktop;};
    pbor.firefox.default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''Make Firefox the default browser.'';
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {config, ...}: {
      programs.firefox = {
        enable = true;
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
            rycee.ublock-origin
            rycee.istilldontcareaboutcookies

            pborzenkov.shiori_ext
          ];
        };
      };

      xdg.mimeApps.defaultApplications = lib.mkIf cfg.default {
        "text/html" = ["firefox.desktop"];
      };
    };
  };
}
