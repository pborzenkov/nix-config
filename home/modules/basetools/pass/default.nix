{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.basetools.pass;
in {
  options = {
    pbor.basetools.pass.enable = (lib.mkEnableOption "Enable pass") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (ext: [ext.pass-otp]);
      settings = {
        PASSWORD_STORE_DIR = "$XDG_DATA_HOME/password-store";
      };
    };
  };
}
