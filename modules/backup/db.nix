{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.backup;
in {
  options.pbor.backup.dbBackups = lib.mkOption {
    description = ''
      Periodic backups of the databases.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          database = lib.mkOption {
            type = lib.types.str;
            description = ''
              Which database to backup.
            '';
            example = "miniflux";
          };
        };
      }
    );
    default = {};
    example = {
      miniflux = {
        database = "miniflux";
      };
    };
  };

  config = let
    exporter = pkgs.writeShellScriptBin "restic-exporter" (builtins.readFile ./restic-exporter.sh);
  in {
    systemd.services =
      lib.mapAttrs'
      (
        name: backup: let
          extraOptions = lib.concatMapStrings (arg: " -o ${arg}") config.lib.pbor.backup.extraOptions;
          resticCmd = "${pkgs.restic}/bin/restic${extraOptions}";
          backupName = "restic-backups-db-${name}";
          pg = config.services.postgresql;
          pgsu = "${pkgs.sudo}/bin/sudo -u ${pg.superUser}";
        in
          lib.nameValuePair backupName {
            environment = {
              RESTIC_PASSWORD_FILE = cfg.passwordFile;
              RESTIC_REPOSITORY = config.lib.pbor.backup.repository;
            };
            path = [pkgs.openssh pkgs.gawk pkgs.gnugrep];
            restartIfChanged = false;
            serviceConfig = {
              Type = "oneshot";
              User = "root";
              RuntimeDirectory = backupName;
              ExecStartPost = "${exporter}/bin/restic-exporter %n";
            };
            script = ''
              set -o pipefail
              ${pgsu} ${pg.package}/bin/pg_dump -c -d ${backup.database} | \
                  ${resticCmd} backup --stdin --stdin-filename /db/${backup.database}.sql
            '';
          }
      )
      cfg.dbBackups;
    systemd.timers =
      lib.mapAttrs'
      (
        name: backup:
          lib.nameValuePair "restic-backups-db-${name}" {
            wantedBy = ["timers.target"];
            timerConfig = config.lib.pbor.backup.timerConfig;
          }
      )
      cfg.dbBackups;
  };
}
