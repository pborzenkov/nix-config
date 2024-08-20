{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.sudo;
in {
  options = {
    pbor.sudo.enable = (lib.mkEnableOption "Enable sudo") // {default = config.pbor.enable;};
  };

  config = lib.mkIf cfg.enable {
    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
