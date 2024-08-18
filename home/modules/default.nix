{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor;
in {
  imports = [
    ./basetools
    ./devtools
    ./filebot
    ./firefox
    ./foot
    ./gpg
    ./helix
    ./media
    ./pim
    ./shell
    ./stylix
    ./taskwarrior
    ./torrents
    ./virt
    ./wm
    ./wofi
    ./zathura
  ];

  options = {
    pbor.enable = (lib.mkEnableOption "Enable custom modules") // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      PATH = "\${HOME}/bin/:\${PATH}";
    };

    home.packages = with pkgs;
      lib.mkIf isDesktop [
        anki
        bashmount
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
}
