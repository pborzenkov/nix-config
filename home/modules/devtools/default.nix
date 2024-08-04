{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.devtools;
in {
  imports = [
    ./direnv
    ./lang
    ./networking
    ./reversing
  ];

  options = {
    pbor.devtools.enable = (lib.mkEnableOption "Enable devtools") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zeal
      man-pages
      man-pages-posix
      gnumake
      just
      prox
    ];
  };
}
