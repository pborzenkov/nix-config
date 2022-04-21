{ config, pkgs, ... }:

{
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
    "filebot-music" =
      let
        chooseArtwork = pkgs.writeShellScript "filebot-choose-artwork" ''
          sdir="$1"
          ddir="$2"

          images=$(${pkgs.fd}/bin/fd -e jpg -e jpeg -e png -e bmp -a --search-path "$sdir")
          [ -z "$images" ] && exit 0

          result=$(echo "$images" | ${pkgs.imv}/bin/imv -c 'bind a exec echo "$imv_current_file"; quit')
          [ -z "$result" ] && exit 0

          ext="''${result##*.}"
          cp "$result" "''${ddir}/folder.''${ext}"
        ''; in
      {
        target = "bin/filebot-music";
        source = pkgs.writeShellScript "filebot-music" ''
          if [ $# -eq 0 ]; then
            echo "Usage: $0 <path>"
            exit 1
          fi

          ${pkgs.filebot}/bin/filebot -script fn:amc --output /storage/music --action copy --mode interactive \
          --def music=y --def musicFormat="/storage/music/{artist}/{y} - {album}/{pi.pad(02)} - {t}" \
          --def exec="${chooseArtwork} \"$@\" {quote folder}" "$@"
        '';
        executable = true;
      };
  };
}
