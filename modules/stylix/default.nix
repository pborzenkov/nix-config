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

      polarity = "dark";
      cursor = {
        package = pkgs.vimix-cursors;
        name = "Vimix-cursors";
        size = 24;
      };
      icons = {
        enable = true;
        package = pkgs.vimix-icon-theme;
        dark = "Vimix-Doder-dark";
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
        qt = {
          enable = true;
          platform = lib.mkForce "gnome";
        };
        fontconfig.enable = true;
        font-packages.enable = true;
      };
    };

    hm =
      { config, ... }:
      {
        xresources.path = "${config.xdg.configHome}/X11/xresources";
        stylix.targets = {
          gtk.enable = true;
        };
      };
  };
}
