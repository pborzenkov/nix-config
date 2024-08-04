{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.devtools.networking;
in {
  options = {
    pbor.devtools.networking.enable = (lib.mkEnableOption "Enable networking tools") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hurl
      oha
      xh
      gron
      trippy
      curl
      q
    ];
  };
}
