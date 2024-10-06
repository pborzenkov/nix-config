{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.devtools.lang.erlan;
in {
  options = {
    pbor.devtools.lang.erlan.enable = (lib.mkEnableOption "Enable Erlang") // {default = false;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        erlang
        erlang-ls
        rebar3
      ];
    };
  };
}
