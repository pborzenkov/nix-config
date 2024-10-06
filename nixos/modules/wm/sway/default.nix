{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.wm.sway;
in {
  options = {
    pbor.wm.sway.enable = (lib.mkEnableOption "Enable Sway") // {default = config.pbor.wm.enable;};
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraSessionCommands = ''
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export SDL_VIDEODRIVER=wayland
        source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      '';
    };

    xdg.portal = {
      config.sway = {
        default = "gtk";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Inhibit" = "none";
      };
    };
  };
}
