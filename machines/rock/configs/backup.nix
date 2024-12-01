{config, ...}: {
  pbor.backup = {
    host = "zh1012.rsync.net";
    user = "zh1012";
    sshKeyFile = "/etc/ssh/ssh_host_ed25519_key";
    repository = "restic";
    passwordFile = config.sops.secrets.restic-repo-password.path;
    timerConfig = {
      OnCalendar = "02:00";
      RandomizedDelaySec = "1h";
    };

    prune = {
      options = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
      timerConfig = {
        OnCalendar = "07:00";
        RandomizedDelaySec = "2h";
      };
    };
  };

  sops.secrets.restic-repo-password = {};

  programs.ssh.knownHosts."zh1012.rsync.net" = {
    hostNames = ["zh1012.rsync.net"];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtclizeBy1Uo3D86HpgD3LONGVH0CJ0NT+YfZlldAJd";
  };

  pbor.backup.fsBackups = {
    work = {
      paths = [
        "/home/pbor/work"
      ];
      excludes = [
        "**/.terraform/providers"
        "**/src/**/bin/**"
      ];
    };
    docs = {
      paths = [
        "/home/pbor/docs"
      ];
    };
  };
}
