{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  username,
  ...
}:
let
  cfg = config.pbor;
in
{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" username ])
  ]
  ++ pborlib.allDirs ./.;

  options = {
    pbor.enable = (lib.mkEnableOption "Enable custom modules") // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf isDesktop [
      9090 # Calibre sync server
    ];
    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "en_GB.UTF-8/UTF-8"
      ];
      extraLocaleSettings = {
        LC_TIME = "en_GB.UTF-8";
      };
    };

    hm =
      { config, ... }:
      {
        home.sessionVariables = {
          PATH = "\${HOME}/bin/:\${PATH}";
        };

        home.packages =
          with pkgs;
          lib.mkIf isDesktop [
            anki
            goldendict-ng
            bashmount
            brightnessctl
            calibre
            cliflux
            libreoffice
            telegram-desktop
            zoom-us
            obsidian
          ];

        home.file.".local/share/dictionaries/hunspell".source =
          let
            dicts = pkgs.symlinkJoin {
              name = "hunspell-dicts";
              paths = with pkgs.hunspellDicts; [
                en-us-large
                en-gb-large
                nl_nl
              ];
            };
          in
          "${dicts}/share/hunspell";

        xdg = {
          enable = true;
          mimeApps = {
            enable = isDesktop;
            defaultApplications = lib.mkIf isDesktop {
              "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
            };
          };
          userDirs.download = "${config.home.homeDirectory}/down";
        };

        lib.pbor.syncStateFor =
          program: file:
          config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/synced-state/${program}/${file}";
      };
  };
}
