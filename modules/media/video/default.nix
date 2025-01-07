{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}: let
  cfg = config.pbor.media.video;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.media.video.enable = (lib.mkEnableOption "Enable video") // {default = config.pbor.media.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      handbrake
      mkvtoolnix
    ];
  };
}
