{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.devtools.git.gh;
in {
  options = {
    pbor.devtools.git.gh.enable = (lib.mkEnableOption "Enable gh") // {default = config.pbor.devtools.git.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm = {
      programs.gh = {
        enable = true;
        settings = {
          editor = "hx";
          git_protocol = "ssh";
        };
      };

      home.packages = with pkgs; [
        prr
      ];
    };
  };
}
