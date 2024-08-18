{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.media.images;
in {
  imports = [
    ./imv
  ];

  options = {
    pbor.media.images.enable = (lib.mkEnableOption "Enable images") // {default = config.pbor.media.enable;};
  };

  config = lib.mkIf cfg.enable {
    home.file."review-photos" = let
      mpvconf = pkgs.writeTextDir "mpv/input.conf" ''
        a run "${pkgs.bash}/bin/bash" "-c" "echo ''${path}"; playlist-remove current
        d playlist-remove current
      '';
    in {
      target = "bin/review-photos";
      source = pkgs.writeShellScript "review-photos" ''
        set -e

        sdir="${config.xdg.dataHome}/photos-for-review"
        ddir="/storage/photos"

        photos=($(${pkgs.fd}/bin/fd -e jpg -e jpeg -e png -e heic -e tiff . "''${sdir}"))
        if [ ''${#photos[@]} -gt 0 ]; then
          keep=($(printf "%s\n" "''${photos[@]}" | ${pkgs.imv}/bin/imv \
            -c 'bind a exec echo "$imv_current_file"; close' \
            -c 'bind d close'))
          for photo in "''${keep[@]}"; do
            date=$(${pkgs.exiftool}/bin/exiftool -json "$photo" | \
              ${pkgs.jq}/bin/jq -r '.[].CreateDate | strptime("%Y:%m:%d %H:%M:%S") | strftime("%Y/%m")')
            dir="''${ddir}/''${date}"
            mkdir -p "$dir"
            cp "$photo" "$dir"
            rm -f "$photo"
          done
        fi

        videos=($(${pkgs.fd}/bin/fd -e mp4 -e mov -e avi -e mkv . "''${sdir}"))
        if [ ''${#videos[@]} -gt 0 ]; then
          keep=($(printf "%s\n" "''${videos[@]}" | ${pkgs.mpv}/bin/mpv --playlist=- \
            --really-quiet \
            --keep-open=always \
            --config-dir=${mpvconf}/mpv
          ))
          for video in "''${keep[@]}"; do
            date=$(${pkgs.exiftool}/bin/exiftool -json "$video" | \
              ${pkgs.jq}/bin/jq -r '.[].CreateDate | strptime("%Y:%m:%d %H:%M:%S") | strftime("%Y/%m")')
            dir="''${ddir}/''${date}"
            mkdir -p "$dir"
            cp "$video" "$dir"
            rm -f "$video"
          done
        fi

        read -p "Keep the rest? (y/n) " yn
        if [ "x$yn" = "xn" ]; then
          rm -rf $sdir/*
        fi
      '';
      executable = true;
    };
  };
}
