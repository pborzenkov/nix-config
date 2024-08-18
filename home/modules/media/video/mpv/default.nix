{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.media.video.mpv;
in {
  options = {
    pbor.media.video.mpv.enable = (lib.mkEnableOption "Enable mpv") // {default = config.pbor.media.video.enable;};
  };

  config = lib.mkIf cfg.enable {
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
  };
}
