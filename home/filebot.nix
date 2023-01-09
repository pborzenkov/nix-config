{
  config,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.filebot
  ];

  home.file = {
    "filebot-movie" = {
      target = "bin/filebot-movie";
      source = pkgs.writeShellScript "filebot-movie" ''
        if [ $# -eq 0 ]; then
          echo "Usage: $0 <path>"
          exit 1
        fi

        ${pkgs.filebot}/bin/filebot -rename -r --output /storage/movies --action hardlink --mode interactive \
        --format "{ ~plex }" --db TheMovieDB "$@"
      '';
      executable = true;
    };
    "filebot-tv-show" = {
      target = "bin/filebot-tv-show";
      source = pkgs.writeShellScript "filebot-tv-show" ''
        if [ $# -eq 0 ]; then
          echo "Usage: $0 <path>"
          exit 1
        fi

        ${pkgs.filebot}/bin/filebot -rename -r --output /storage/tv-shows --action hardlink --mode interactive \
        --format "{ ~plex }" --db TheTVDB "$@"
      '';
      executable = true;
    };
    "filebot-adult" = {
      target = "bin/filebot-adult";
      source = pkgs.writeShellScript "filebot-adult" ''
        if [ $# -eq 0 ]; then
          echo "Usage: $0 <path>"
          exit 1
        fi

        ${pkgs.filebot}/bin/filebot -rename -r --output /storage/adult --action hardlink --mode interactive \
        --format "{ ~plex }" --db TheMovieDB "$@"
      '';
      executable = true;
    };
  };
}
