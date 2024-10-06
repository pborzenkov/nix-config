{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  username,
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

    programs.adb.enable = true;
    users.users.pbor.extraGroups = ["adbusers"];

    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        zeal
        man-pages
        man-pages-posix
        gnumake
        just
        prox
      ];
    };
  };
}
