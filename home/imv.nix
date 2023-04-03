{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    pkgs.imv
  ];

  xdg.configFile.imv = {
    target = "imv/config";
    text = lib.generators.toINI {} {
      binds = {
        "<Shift+greater>" = "next 1";
        "<Shift+less>" = "prev 1";
      };
    };
  };
}
