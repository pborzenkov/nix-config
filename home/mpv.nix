{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      alang = "eng,en,English";
      slang = "eng,en,English";
    };
  };

  home.packages = [
    pkgs.jellyfin-media-player
  ];
}
