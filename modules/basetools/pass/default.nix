{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.basetools.pass;
in {
  options = {
    pbor.basetools.pass.enable = (lib.mkEnableOption "Enable pass") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {config, ...}: {
      programs.password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (ext: [ext.pass-otp]);
        settings = {
          PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
        };
      };
    };
  };
}
