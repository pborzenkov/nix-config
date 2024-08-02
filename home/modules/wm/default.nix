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
  ];

  options = {
    pbor.wm.enable = (lib.mkEnableOption "Enable WM related things") // {default = config.pbor.enable && isDesktop;};
  };

  config =
    lib.mkIf cfg.enable {
    };
}
