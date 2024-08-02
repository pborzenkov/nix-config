{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.dunst;
in {
  options = {
    pbor.dunst.enable = (lib.mkEnableOption "Enable dunst") // {default = isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
    };
    stylix.targets.dunst.enable = true;
  };
}
