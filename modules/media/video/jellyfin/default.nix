{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.media.video.jellyfin;
in {
  options = {
    pbor.media.video.jellyfin.enable = (lib.mkEnableOption "Enable Jellyfin") // {default = config.pbor.media.video.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm = {
      osConfig,
      config,
      ...
    }: {
      home.packages = with pkgs; [
        jellyfin-media-player
      ];

      xdg.dataFile."jellyfinmediaplayer/mpv.conf" = lib.mkIf osConfig.pbor.media.video.mpv.enable {
        source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/mpv/mpv.conf";
      };

      wayland.windowManager.sway.config.window.commands = lib.mkIf osConfig.pbor.wm.sway.enable [
        {
          criteria = {app_id = "com.github.iwalton3.jellyfin-media-player";};
          command = "inhibit_idle visible";
        }
      ];
    };
  };
}
