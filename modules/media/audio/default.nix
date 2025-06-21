{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.media.audio;
in
{
  imports = pborlib.allDirs ./.;

  options = {
    pbor.media.audio.enable = (lib.mkEnableOption "Enable audio") // {
      default = config.pbor.media.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      home = {
        packages = with pkgs; [
          playerctl
          pulseaudio
          ncpamixer
          picard
          shntool
          flac
          cuetools
        ];

        shellAliases = {
          unflac = ''${pkgs.unflac}/bin/unflac -n "{{.Input.Artist | Elem}} - {{with .Input.Title}}{{. | Elem}}{{else}}Unknown Album{{end}} ({{- with .Input.Date}}{{.}}{{end}})/ {{- printf .Input.TrackNumberFmt .Track.Number}} - {{.Track.Title | Elem}}"'';
        };
      };

      services.playerctld.enable = true;
    };
  };
}
