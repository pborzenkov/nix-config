{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.devtools.reversing;
in {
  options = {
    pbor.devtools.reversing.enable = (lib.mkEnableOption "Enable reversing tools") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        binutils
        radare2
        gdb
      ];
    };
  };
}
