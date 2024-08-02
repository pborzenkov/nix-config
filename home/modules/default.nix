{
  config,
  lib,
  ...
}: let
  cfg = config.pbor;
in {
  imports = [
    ./basetools
    ./foot
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
  };
}
