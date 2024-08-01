{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.basetools.bat;
in {
  options = {
    pbor.basetools.bat.enable = (lib.mkEnableOption "Enable bat") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batman
      ];
    };
    stylix.targets.bat.enable = true;

    home.shellAliases = {
      man = "batman";
    };
  };
}
