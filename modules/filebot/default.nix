{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.filebot;
in {
  options = {
    pbor.filebot.enable = (lib.mkEnableOption "Enable filebot") // {default = config.pbor.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm = {
      home = {
        packages = [
          pkgs.filebot
        ];

        file = let
          scripts = [
            {
              name = "movie";
              dir = "movies";
              db = "TheMovieDB";
            }
            {
              name = "tv-show";
              dir = "tv-shows";
              db = "TheTVDB";
            }
            {
              name = "adult";
              dir = "adult";
              db = "TheMovieDB";
            }
          ];

          mkFilebotScript = args: {
            source = pkgs.writeShellScript "filebot-${args.name}" ''
              if [ $# -eq 0 ]; then
                echo "Usage: $0 <path> [args]"
                exit 1
              fi

              ${pkgs.filebot}/bin/filebot -rename -r --output /storage/${args.dir} --action hardlink \
                --mode interactive --format "{ ~plex }" --db ${args.db} "$@"
            '';
            executable = true;
          };
        in
          builtins.listToAttrs (
            builtins.map (args: {
              name = "bin/filebot-${args.name}";
              value = mkFilebotScript args;
            })
            scripts
          );
      };
    };
  };
}
