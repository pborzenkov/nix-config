{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.torrents;
  upload-assistant = pkgs.writeShellApplication {
    name = "upload-assistant";
    text = ''
      docker pull ghcr.io/audionut/upload-assistant:master
      exec docker run --rm -ti --network host \
        -v /home/pbor/.config/upload-assistant/config.py:/Upload-Assistant/data/config.py \
        -v /storage/torrents:/storage/torrents \
        ghcr.io/audionut/upload-assistant:master "$@"
    '';
  };
in
{
  options = {
    pbor.torrents.enable = (lib.mkEnableOption "Enable torrents") // {
      default = config.pbor.enable && isDesktop;
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      home.packages = with pkgs; [
        rustmission
        upload-assistant
      ];

      xdg.configFile."rustmission/config.toml" = {
        source = (pkgs.formats.toml { }).generate "rustmission.toml" {
          connection = {
            url = "https://torrents.lab.borzenkov.net/transmission/rpc";
          };
        };
      };
    };
  };
}
