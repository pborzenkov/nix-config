{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.stylix;
in {
  options = {
    pbor.stylix.enable = (lib.mkEnableOption "Enable stylix") // {default = true;};
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = false;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";

      cursor = {
        package = pkgs.vimix-cursors;
        name = "Vimix-cursors";
        size = 24;
      };

      fonts = {
        monospace = {
          name = "MesloLGS Nerd Font Mono";
          package = pkgs.nerdfonts;
        };

        sizes = {
          terminal = 10;
        };
      };
    };

    home.pointerCursor = {
      x11.enable = lib.mkForce isDesktop;
      gtk.enable = lib.mkForce isDesktop;
    };
  };
}
