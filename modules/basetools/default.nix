{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.basetools;
in
{
  imports = pborlib.allDirs ./.;

  options = {
    pbor.basetools.enable = (lib.mkEnableOption "Enable basetools") // {
      default = config.pbor.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
        home = {
          packages = with pkgs; [
            moreutils
            findutils
            file
            bc
            zip
            unzip
            unrar
            ouch
            usbutils
            pciutils
            dmidecode
            sd
            md-tui
            iproute2
            sqlite
            systemctl-tui
            dtach
          ];
          sessionVariables = {
            PARALLEL_HOME = "${config.xdg.configHome}/parallel";
          };
        };
      };
    # TODO: md-tui configuration
  };
}
