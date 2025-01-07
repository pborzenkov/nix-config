{
  config,
  lib,
  pkgs,
  pborlib,
  ...
}: let
  cfg = config.pbor.media.images;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.media.images.enable = (lib.mkEnableOption "Enable images") // {default = config.pbor.media.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm = {config, ...}: {
      home.packages = [
        pkgs.immich-cli
      ];

      home.sessionVariables = {
        "IMMICH_CONFIG_DIR" = "${config.xdg.configHome}/immich";
      };
    };
  };
}
