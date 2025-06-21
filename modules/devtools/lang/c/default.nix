{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.devtools.lang.c;
in
{
  options = {
    pbor.devtools.lang.c.enable = (lib.mkEnableOption "Enable C/C++") // {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      (lib.hiPrio gcc)
      clang
      gdb
      lldb
      clang-analyzer
      clang-tools
      clang-manpages
    ];
  };
}
