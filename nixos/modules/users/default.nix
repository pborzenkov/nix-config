{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.users;
in {
  options = {
    pbor.users.enable = (lib.mkEnableOption "Enable users") // {default = config.pbor.enable;};
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;

    users = {
      mutableUsers = true;

      users.pbor = {
        description = "Pavel Borzenkov";
        uid = 1000;
        extraGroups = [
          "wheel"
          "podman"
        ];
        initialHashedPassword = "$6$Se632pcey47f$lnay/DQrEwkr2v10omhbQub0J0rSsPT/9hhs.5uawW8F9bTsO.imtZeeEs5XGrAHOckRw62camiszHjEUwgmM1";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTeiZ5C7zFAkxo5HGMZfxdAbDtLp6Ktv304NwrhKvkl cardno:000614470090"
        ];
        shell = pkgs.fish;
      };
    };
  };
}
