{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.devtools;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.devtools.enable = (lib.mkEnableOption "Enable devtools") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      config.boot.kernelPackages.perf
    ];

    hm.home.packages = with pkgs; [
      zeal
      man-pages
      man-pages-posix
      gnumake
      just
      prox
    ];
  };
}
