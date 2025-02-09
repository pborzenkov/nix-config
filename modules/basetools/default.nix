{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}: let
  cfg = config.pbor.basetools;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.basetools.enable = (lib.mkEnableOption "Enable basetools") // {default = config.pbor.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      moreutils
      findutils
      file
      bc
      zip
      unzip
      unrar
      usbutils
      pciutils
      dmidecode
      sd
      md-tui
      iproute2
      sqlite
    ];
  };

  # TODO: md-tui configuration
}
