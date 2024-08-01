{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.zathura;
in {
  options = {
    pbor.zathura.enable = (lib.mkEnableOption "Enable zathura") // {default = isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      options = {
        continuous-hist-save = true;
        selection-clipboard = "clipboard";
        guioptions = "";
      };
    };
    stylix.targets.zathura.enable = true;

    home.file = let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
      synced-state = "${config.home.homeDirectory}/.local/share/synced-state/zathura";
    in {
      ".local/share/zathura/bookmarks".source = mkSymlink "${synced-state}/bookmarks";
      ".local/share/zathura/history".source = mkSymlink "${synced-state}/history";
      ".local/share/zathura/input-history".source = mkSymlink "${synced-state}/input-history";
    };
  };
}
