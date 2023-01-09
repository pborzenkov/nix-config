{
  config,
  pkgs,
  ...
}: {
  programs.mpv = {
    enable = true;
    config = {
      alang = "eng,en,English";
      slang = "eng,en,English";
    };
  };
}
