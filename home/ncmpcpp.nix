{
  config,
  pkgs,
  ...
}: {
  programs.ncmpcpp = {
    enable = true;
    mpdMusicDir = null;
    bindings = [
      {
        key = "j";
        command = "scroll_down";
      }
      {
        key = "k";
        command = "scroll_up";
      }
      {
        key = "l";
        command = "next_column";
      }
      {
        key = "h";
        command = "previous_column";
      }
    ];
    settings = {
      media_library_primary_tag = "album_artist";
      media_library_hide_album_dates = true;
    };
  };

  home.packages = [
    pkgs.mpc_cli
  ];
}
