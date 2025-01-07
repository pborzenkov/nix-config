{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  username,
  ...
}: let
  cfg = config.pbor;
in {
  imports =
    [
      (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])
    ]
    ++ pborlib.allDirs ./.;

  options = {
    pbor.enable = (lib.mkEnableOption "Enable custom modules") // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf isDesktop [
      9090 # Calibre sync server
    ];

    hm = {config, ...}: {
      home.sessionVariables = {
        PATH = "\${HOME}/bin/:\${PATH}";
      };

      home.packages = with pkgs;
        lib.mkIf isDesktop [
          anki
          bashmount
          brightnessctl
          calibre
          libreoffice
          tdesktop
          zoom-us
        ];

      xdg = {
        mimeApps = {
          enable = isDesktop;
          defaultApplications = lib.mkIf isDesktop {
            "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
          };
        };
        userDirs.download = "${config.home.homeDirectory}/down";
      };

      lib.pbor.syncStateFor = program: file:
        config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/synced-state/${program}/${file}";
    };
  };
}
