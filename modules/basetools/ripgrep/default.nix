{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.basetools.ripgrep;
in {
  options = {
    pbor.basetools.ripgrep.enable = (lib.mkEnableOption "Enable ripgrep") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.ripgrep = {
        enable = true;
        arguments = [
          "--smart-case"
        ];
      };

      home.packages = [
        pkgs.ripgrep-all
      ];
    };
  };
}
