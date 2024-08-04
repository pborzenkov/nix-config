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
    ./foot
    ./gpg
    ./helix
    ./shell
    ./stylix
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
  };
}
