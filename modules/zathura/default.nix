{
  config,
  lib,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.zathura;
in
{
  options = {
    pbor.zathura.enable = (lib.mkEnableOption "Enable zathura") // {
      default = config.pbor.enable && isDesktop;
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
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

        home.file.".local/share/zathura/bookmarks.sqlite".source =
          config.lib.pbor.syncStateFor "zathura" "bookmarks.sqlite";

        xdg.mimeApps.defaultApplications = {
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
          "application/epub+zip" = [ "org.pwmt.zathura.desktop" ];
        };
      };
  };
}
