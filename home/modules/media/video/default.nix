{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.media.video;
in {
  imports = [
    ./mpv
    ./jellyfin
  ];

  options = {
    pbor.media.video.enable = (lib.mkEnableOption "Enable video") // {default = config.pbor.media.enable;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      handbrake
      mkvtoolnix
    ];
  };
}
