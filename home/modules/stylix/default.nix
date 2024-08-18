{
  config,
  lib,
  pkgs,
  inputs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.stylix;
in {
  options = {
    pbor.stylix.enable = (lib.mkEnableOption "Enable stylix") // {default = config.pbor.enable;};
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
        emoji = {
          name = "Noto Emoji";
          package = pkgs.noto-fonts-monochrome-emoji;
        };
        monospace = {
          name = "MesloLGS Nerd Font Mono";
          package = pkgs.nerdfonts;
        };
        sansSerif = {
          name = "DejaVu Sans";
          package = pkgs.dejavu_fonts;
        };
        serif = {
          name = "DejaVu Serif";
          package = pkgs.dejavu_fonts;
        };

        sizes = {
          applications = 10;
          desktop = 10;
          popups = 12;
          terminal = 10;
        };
      };

      image = "${inputs.self}/assets/wallpaper.jpg";
      imageScalingMode = "fill";

      targets.gtk.enable = isDesktop;
    };

    home = {
      pointerCursor = {
        x11.enable = lib.mkForce isDesktop;
        gtk.enable = lib.mkForce isDesktop;
      };
      packages = with pkgs;
        lib.mkIf isDesktop [
          font-awesome_6
        ];
    };

    gtk = {
      enable = isDesktop;
      theme = {
        name = lib.mkForce "vimix-dark-doder";
        package = lib.mkForce pkgs.vimix-gtk-themes;
      };
      iconTheme = {
        name = "Vimix-Doder-dark";
        package = pkgs.vimix-icon-theme;
      };
    };
  };
}
