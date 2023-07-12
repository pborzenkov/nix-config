{
  config,
  inputs,
  ...
}: {
  programs.zathura = {
    enable = true;
    options = {
      continuous-hist-save = true;
      selection-clipboard = "clipboard";
    };
    extraConfig = builtins.readFile (config.scheme inputs.base16-zathura);
  };

  home.file = let
    mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    synced-state = "${config.home.homeDirectory}/.local/share/synced-state/zathura";
  in {
    ".local/share/zathura/bookmarks".source = mkSymlink "${synced-state}/bookmarks";
    ".local/share/zathura/history".source = mkSymlink "${synced-state}/history";
    ".local/share/zathura/input-history".source = mkSymlink "${synced-state}/input-history";
  };
}
