{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.basetools.jq;
in {
  options = {
    pbor.basetools.jq.enable = (lib.mkEnableOption "Enable jq") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm.programs.jq = {
      enable = true;
    };
  };
}
