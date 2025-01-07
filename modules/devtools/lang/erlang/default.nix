{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.devtools.lang.erlan;
in {
  options = {
    pbor.devtools.lang.erlan.enable = (lib.mkEnableOption "Enable Erlang") // {default = false;};
  };

  config = lib.mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      erlang
      erlang-ls
      rebar3
    ];
  };
}
