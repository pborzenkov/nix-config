{
  pkgs,
  config,
  ...
}: {
  programs.mpv = {
    enable = true;
    config = {
      alang = "eng,en,English";
      slang = "eng,en,English";
      vo = "dmabuf-wayland";
      gpu-api = "vulkan";
      hwdec = "auto";
      gpu-context = "waylandvk";
      hdr-compute-peak = "no";
    };
  };

  home.packages = [
    pkgs.jellyfin-media-player
  ];

  xdg.dataFile."jellyfinmediaplayer/mpv.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/mpv/mpv.conf";
  };

  wayland.windowManager.sway.config.window.commands = [
    {
      criteria = {app_id = "org.jellyfin.";};
      command = "inhibit_idle visible";
    }
  ];
}
