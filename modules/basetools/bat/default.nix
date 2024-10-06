{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.basetools.bat;
in {
  options = {
    pbor.basetools.bat.enable = (lib.mkEnableOption "Enable bat") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
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
  };
}
