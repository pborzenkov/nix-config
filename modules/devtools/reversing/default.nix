{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.devtools.reversing;
in {
  options = {
    pbor.devtools.reversing.enable = (lib.mkEnableOption "Enable reversing tools") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      binutils
      radare2
      gdb
    ];
  };
}
