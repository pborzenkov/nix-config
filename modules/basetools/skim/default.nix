{
  config,
  lib,
  ...
}:
let
  cfg = config.pbor.basetools.skim;
in
{
  options = {
    pbor.basetools.skim.enable = (lib.mkEnableOption "Enable skim") // {
      default = config.pbor.basetools.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm.programs.skim = {
      enable = true;
      enableFishIntegration = true;

      defaultCommand = lib.optionalString config.pbor.basetools.fd.enable "fd --type f";
      fileWidgetCommand = lib.optionalString config.pbor.basetools.fd.enable "fd --type f";
    };
  };
}
