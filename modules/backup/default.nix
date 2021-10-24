{ config, lib, pkgs, ... }:

let
  opTimeConfig = {
    OnCalendar = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = ''
        When to run the operation. See man systemd.timer for details.
      '';
    };
    RandomizedDelaySec = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Delay the operation by a randomly selected, evenly distributed
        amount of time between 0 and the specified time value.
      '';
      example = "5h";
    };
  };
in
{
  imports = [
    ./fs.nix
    ./db.nix
  ];

  options.backup = {
    host = lib.mkOption {
      type = lib.types.str;
      description = ''
        Target host for SFTP backup.
      '';
      example = "zh1012.rsync.net";
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = ''
        User on the target host.
      '';
      example = "zh1012";
    };

    sshKeyFile = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        File containing the SSH private key.
      '';
    };

    repository = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path to Restic repository on the target host.
      '';
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        File containing Restic repository password.
      '';
      example = "/etc/nixos/restic-password";
    };

    timerConfig = opTimeConfig;

    prune = {
      options = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = ''
          A list of options (--keep-* et al.) for 'restic forget
          --prune', to automatically prune old snapshots.
        '';
        example = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 75"
        ];
      };
      timerConfig = opTimeConfig;
    };
  };

  config = let
    cfg = config.backup;

    hostKeyAlgos = "-o HostKeyAlgorithms=ssh-ed25519";
    sshKeyFile = lib.optionalString (cfg.sshKeyFile != null) "-i ${cfg.sshKeyFile}";
    sftpCommand = "ssh ${cfg.user}@${cfg.host} ${sshKeyFile} ${hostKeyAlgos} -s sftp";

    pruneName = "restic-backups-prune";
  in
    {
      lib.backup.repository = "sftp::${cfg.repository}";
      lib.backup.extraOptions = [
        "sftp.command='${sftpCommand}'"
      ];
      lib.backup.timerConfig = {
        OnCalendar = cfg.timerConfig.OnCalendar;
      } // lib.optionalAttrs (cfg.timerConfig.RandomizedDelaySec != null) {
        RandomizedDelaySec = cfg.timerConfig.RandomizedDelaySec;
      };

      systemd.services."${pruneName}" = let
        extraOptions = lib.concatMapStrings (arg: " -o ${arg}") config.lib.backup.extraOptions;
        resticCmd = "${pkgs.restic}/bin/restic${extraOptions}";
      in
        lib.mkIf (builtins.length cfg.prune.options > 0) {
          environment = {
            RESTIC_PASSWORD_FILE = cfg.passwordFile;
            RESTIC_REPOSITORY = config.lib.backup.repository;
          };
          path = [ pkgs.openssh ];
          restartIfChanged = false;
          serviceConfig = {
            Type = "oneshot";
            ExecStart = [
              (resticCmd + " forget --prune " + (lib.concatStringsSep " " cfg.prune.options))
              (resticCmd + " check")
            ];
            User = "root";
            RuntimeDirectory = pruneName;
            CacheDirectory = pruneName;
            CacheDirectoryMode = "0700";
          };
        };
      systemd.timers."${pruneName}" = lib.mkIf (builtins.length cfg.prune.options > 0) {
        wantedBy = [ "timers.target" ];
        timerConfig = cfg.prune.timerConfig;
      };
    };
}
