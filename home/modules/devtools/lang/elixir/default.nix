{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.devtools.lang.elixir;
in {
  options = {
    pbor.devtools.lang.elixir.enable = (lib.mkEnableOption "Enable Elixir") // {default = false;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      elixir
      elixir-ls
    ];
  };
}
