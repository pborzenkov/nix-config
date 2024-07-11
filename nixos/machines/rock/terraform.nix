{config, ...}: {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = ["tf_infra"];
    authentication = ''
      host  all all 192.168.88.0/24 md5
    '';
  };

  systemd.services.postgresql = {
    postStart = ''
      PSQL="psql --port=${toString config.services.postgresql.settings.port}"

      $PSQL -tAc "SELECT 1 FROM pg_roles WHERE rolname='terraform'" | grep -q 1 || $PSQL -tAc "CREATE USER terraform PASSWORD '$TERRAFORM_PG_PASSWORD'"
      $PSQL -tAc 'GRANT ALL PRIVILEGES ON DATABASE tf_infra TO "terraform"'
    '';
    serviceConfig.EnvironmentFile = [
      config.sops.secrets.terraform-pg.path
    ];
  };

  backup.dbBackups.tf_infra = {
    database = "tf_infra";
  };

  sops.secrets.terraform-pg = {};

  networking.firewall.allowedTCPPorts = [5432];
}
