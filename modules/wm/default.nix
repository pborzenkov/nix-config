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

    hm = {config, ...}: {
      home.packages = with pkgs; [
        wev
        wl-clipboard
        xdg-utils
      ];

      xdg.configFile."uwsm/env".text = ''
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export NIXOS_OZONE_WL=1
        export SDL_VIDEODRIVER=wayland,x11
        export GRIM_DEFAULT_DIR="${config.home.homeDirectory}/down"
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent";
        export PATH="$PATH:$HOME/bin"
      '';
    };
  };
}
