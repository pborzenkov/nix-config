{ config, pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "capitaine-cursors";
      cursor-size = 24;
    };
  };
}
