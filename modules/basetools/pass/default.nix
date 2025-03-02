{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.basetools.pass;
in {
  options = {
    pbor.basetools.pass.enable = (lib.mkEnableOption "Enable pass") // {default = false;};
  };

  config = lib.mkIf cfg.enable {
    hm = {config, ...}: {
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
