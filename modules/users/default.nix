{
  config,
  lib,
  ...
}:
let
  cfg = config.pbor.users;
in
{
  options = {
    pbor.users.enable = (lib.mkEnableOption "Enable users") // {
      default = config.pbor.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      mutableUsers = true;

      users.pbor = {
        description = "Pavel Borzenkov";
        uid = 1000;
        hashedPassword = "$y$j9T$Pzfr6h.OMI35.5RCsl41O.$/tfLan8cySmgzE6byxkZcIS2q50q5WG2o26fb2V21V/";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTeiZ5C7zFAkxo5HGMZfxdAbDtLp6Ktv304NwrhKvkl cardno:000614470090"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4QUhUEx86Z3yZA5he14ESuJoruBQBSiPSlK4Jn437M metal"
        ];
      };
    };
  };
}
