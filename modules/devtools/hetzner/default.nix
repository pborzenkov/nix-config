{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.devtools.hetzner;
in
{
  options = {
    pbor.devtools.hetzner.enable = (lib.mkEnableOption "Enable hetzner tools") // {
      default = config.pbor.devtools.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      hcloud
    ];
  };
}
