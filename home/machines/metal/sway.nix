{ config, pkgs, ... }:

{
  wayland.windowManager.sway = {
    config.output = {
      "DP-2" = {
        scale = "2";
      };
    };
  };
}
