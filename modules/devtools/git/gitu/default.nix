{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.devtools.git.gitu;
in {
  options = {
    pbor.devtools.git.gitu.enable = (lib.mkEnableOption "Enable gitu") // {default = config.pbor.devtools.git.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      gitu
    ];
  };

  # TODO: theme
}
