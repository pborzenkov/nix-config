{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.zathura;
in {
  options = {
    pbor.zathura.enable = (lib.mkEnableOption "Enable zathura") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      options = {
        continuous-hist-save = true;
        selection-clipboard = "clipboard";
        guioptions = "";
        database = "sqlite";
      };
    };
    stylix.targets.zathura.enable = true;

    home.file = let
      mkSymlink = f: (
        config.lib.file.mkOutOfStoreSymlink
        "${config.xdg.dataHome}/synced-state/zathura/${f}"
      );
    in {
      ".local/share/zathura/bookmarks.sqlite".source = mkSymlink "bookmarks.sqlite";
    };

    xdg.mimeApps.defaultApplications = {
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "application/epub+zip" = ["org.pwmt.zathura.desktop"];
    };
  };
}
