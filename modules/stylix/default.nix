{
  config,
  lib,
  pkgs,
  inputs,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.stylix;
in
{
  options = {
    pbor.stylix.enable = (lib.mkEnableOption "Enable stylix") // {
      default = config.pbor.enable && isDesktop;
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      corefonts
      font-awesome_5
      font-awesome_6
    ];

    stylix = {
      enable = true;
      autoEnable = false;
      homeManagerIntegration = {
        autoImport = true;
        followSystem = true;
      };

      cursor = {
        package = pkgs.unstable.vimix-cursors;
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
          package = pkgs.nerd-fonts.meslo-lg;
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

      targets = {
        gtk.enable = true;
        qt.enable = true;
        fontconfig.enable = true;
        font-packages.enable = true;
      };
    };

    hm =
      { config, ... }:
      {
        gtk = {
          enable = true;
          gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
          theme = {
            name = lib.mkForce "vimix-dark-doder";
            package = lib.mkForce pkgs.vimix-gtk-themes;
          };
          iconTheme = {
            name = "Vimix-Doder-dark";
            package = pkgs.vimix-icon-theme;
          };
        };
        xresources.path = "${config.xdg.configHome}/X11/xresources";
      };
  };
}
