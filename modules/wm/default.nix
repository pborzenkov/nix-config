{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.wm;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.wm.enable = (lib.mkEnableOption "Enable WM") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        };
      };
    };

    hm.home.packages = with pkgs; [
      wl-clipboard
      xdg-utils
    ];
  };
}
