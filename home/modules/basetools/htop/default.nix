{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.basetools.htop;
in {
  options = {
    pbor.basetools.htop.enable = (lib.mkEnableOption "Enable htop") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    programs.htop = {
      enable = true;
    };
  };
}
