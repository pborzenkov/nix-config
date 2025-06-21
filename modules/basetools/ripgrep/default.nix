{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.basetools.ripgrep;
in
{
  options = {
    pbor.basetools.ripgrep.enable = (lib.mkEnableOption "Enable ripgrep") // {
      default = config.pbor.basetools.enable;
    };
    pbor.basetools.ripgrep.all.enable = (lib.mkEnableOption "Enable ripgrep-all") // {
      default = cfg.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      programs.ripgrep = {
        enable = true;
        arguments = [
          "--smart-case"
        ];
      };

      home.packages = [ ] ++ lib.optional cfg.all.enable pkgs.ripgrep-all;
    };
  };
}
