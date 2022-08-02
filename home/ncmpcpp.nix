{ config, pkgs, ... }:

{
  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = null;
    bindings = [
      { key = "j"; command = "scroll_down"; }
      { key = "k"; command = "scroll_up"; }
      { key = "l"; command = "next_column"; }
      { key = "h"; command = "previous_column"; }
    ];
  };

  home.packages = [
    pkgs.mpc_cli
  ];
}
