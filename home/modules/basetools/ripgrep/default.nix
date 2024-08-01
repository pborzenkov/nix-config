{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.basetools.ripgrep;
in {
  options = {
    pbor.basetools.ripgrep.enable = (lib.mkEnableOption "Enable ripgrep") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
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
}
