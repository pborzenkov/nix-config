{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.wm;
in {
  imports = [
    ./dunst
    ./i3status
    ./sway
  ];

  options = {
    pbor.wm.enable = (lib.mkEnableOption "Enable WM related things") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      GRIM_DEFAULT_DIR = "${config.home.homeDirectory}/down";
    };
  };
}
