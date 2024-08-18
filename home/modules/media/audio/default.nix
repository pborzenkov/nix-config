{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.media.audio;
in {
  imports = [
    ./mpd
  ];

  options = {
    pbor.media.audio.enable = (lib.mkEnableOption "Enable audio") // {default = config.pbor.media.enable;};
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        playerctl
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
}
