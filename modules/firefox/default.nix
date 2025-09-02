{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.firefox;
in
{
  imports = pborlib.allDirs ./.;

  options = {
    pbor.firefox.enable = (lib.mkEnableOption "Enable firefox") // {
      default = config.pbor.enable && isDesktop;
    };
    pbor.firefox.default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''Make Firefox the default browser.'';
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
        programs.firefox = {
          enable = true;
          profiles.default = {
            id = 0;
            isDefault = true;
            name = "default";
            search = {
              force = true;
              default = "Kagi";
              engines = {
                "Kagi" = {
                  urls = [
                    {
                      template = "https://kagi.com/search?";
                      params = [
                        {
                          name = "q";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                };
              };
            };

            settings = {
              "browser.download.folderList" = 2;
              "browser.download.dir" = "${config.home.homeDirectory}/down";
              "browser.startup.page" = 3;
              "browser.warnOnQuitShortcut" = false;

              "signon.rememberSignons" = false;
            };

            extensions = {
              packages =
                let
                  rycee = pkgs.nur.repos.rycee.firefox-addons;
                in
                [
                  rycee.bitwarden
                  rycee.istilldontcareaboutcookies
                  rycee.ublock-origin
                  rycee.linkding-extension
                  rycee.linkding-injector
                ];
              force = true;
            };
          };
        };
        stylix.targets.firefox = {
          enable = true;
          profileNames = [ "default" ];
          colorTheme.enable = true;
        };

        xdg.mimeApps.defaultApplications = lib.mkIf cfg.default {
          "text/html" = [ "firefox.desktop" ];
        };
      };
  };
}
