{
  config,
  pkgs,
  lib,
  ...
}: {
  xdg.configFile.orpheus = {
    target = "orpheus/config.tmpl";
    text = lib.generators.toINI {} {
      orpheus = {
        username = "pbor";
        password = "%REPLACE_ME%";
        data_dir = "/storage/torrents";
        output_dir = "/storage/torrents";
        torrent_dir = "~/torrents";
        formats = "flac, v0, 320";
        media = "blu-ray, dvd, web, cd, vinyl, sacd, dat, soundboard";
        "24bit_behaviour" = 0;
        tracker = "https://home.opsfet.ch/";
        mode = "both";
        api = "https://orpheus.network";
        source = "OPS";
      };
    };
  };

  home.packages = let
    orpheus = pkgs.writeScriptBin "orpheus" ''
      ${pkgs.coreutils}/bin/cat ${config.xdg.configHome}/orpheus/config.tmpl | \
        ${pkgs.sd}/bin/sd \
          '%REPLACE_ME%' \
          $(${config.programs.password-store.package}/bin/pass show www/orpheus.network | ${pkgs.coreutils}/bin/head -1) > \
        ''${XDG_RUNTIME_DIR}/.orpheus.config

      trap 'rm -f "''${XDG_RUNTIME_DIR}/.orpheus.config"' EXIT

      ${pkgs.nur.repos.pborzenkov.orpheusbetter-crawler}/bin/orpheusbetter \
        --config ''${XDG_RUNTIME_DIR}/.orpheus.config \
        --cache ''${HOME}/.cache/orpheus \
        --threads 8 "$@"

      ${pkgs.findutils}/bin/find ~/torrents \
        -maxdepth 1 \
        -type f \
        -exec ${pkgs.transmission}/bin/transmission-remote \
          https://torrents.lab.borzenkov.net/transmission --add '{}' -L ratio \;

      ${pkgs.coreutils}/bin/rm -f ~/torrents/*.torrent
    '';
  in [
    orpheus
    pkgs.mktorrent
  ];

  home.file.orpheus-version = {
    target = ".orpheusbetter/.version";
    text = pkgs.nur.repos.pborzenkov.orpheusbetter-crawler.version;
  };
}
