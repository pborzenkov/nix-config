{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.media;
in {
  imports = [
    ./audio
    ./video
  ];

  options = {
    pbor.media.enable = (lib.mkEnableOption "Enable media") // {default = config.pbor.enable && isDesktop;};
  };

  config =
    lib.mkIf cfg.enable {
    };
}
