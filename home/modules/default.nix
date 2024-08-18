{
  config,
  lib,
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

    xdg = {
      mimeApps.enable = isDesktop;
      userDirs.download = "${config.home.homeDirectory}/down";
    };

    lib.pbor.syncStateFor = program: file:
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/synced-state/${program}/${file}";
  };
}
