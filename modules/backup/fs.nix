{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.backup;
in {
  options.backup.fsBackups = lib.mkOption {
    description = ''
      Periodic backups of the filesystem.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          paths = lib.mkOption {
            type = with lib.types; listOf str;
            default = [];
            description = ''
              Which paths to backup.
            '';
            example = [
              "/var/lib/postgresql"
              "/home/user/backup"
            ];
          };

          excludes = lib.mkOption {
            type = with lib.types; listOf str;
            default = [];
            description = ''
              List of patters to exclude from backup.
            '';
            example = [
              "**/.git"
            ];
          };
        };
      }
    );
    default = {};
    example = {
      home = {
        paths = ["/home"];
      };
      music = {
        paths = ["/storage/music"];
      };
    };
  };

  config = let
    exporter = pkgs.writeShellScriptBin "restic-exporter" (builtins.readFile ./restic-exporter.sh);
  in {
    services.restic.backups =
      lib.mapAttrs'
      (
        name: backup:
          lib.nameValuePair "fs-${name}" {
            repository = config.lib.backup.repository;
            passwordFile = cfg.passwordFile;
            extraOptions = config.lib.backup.extraOptions;
            extraBackupArgs = (map (x: "--exclude ${x}") backup.excludes) ++ ["--exclude-caches"];
            paths = backup.paths;
            timerConfig = config.lib.backup.timerConfig;
          }
      )
      cfg.fsBackups;

    systemd.services =
      lib.mapAttrs'
      (
        name: backup:
          lib.nameValuePair "restic-backups-fs-${name}" {
            path = [pkgs.gawk pkgs.gnugrep];
            serviceConfig.ExecStartPost = "${exporter}/bin/restic-exporter %n";
          }
      )
      cfg.fsBackups;
  };
}
