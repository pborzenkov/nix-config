{
  config,
  lib,
  pborlib,
  ...
}: let
  cfg = config.pbor.media.images;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.media.images.enable = (lib.mkEnableOption "Enable images") // {default = config.pbor.media.enable;};
  };

  config =
    lib.mkIf cfg.enable {
    };
}
