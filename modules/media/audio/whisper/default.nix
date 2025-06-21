{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.media.audio.whisper;

  whisper = pkgs.whisper-cpp.override {
    rocmSupport = cfg.rocm;
  };

  whisper-subtitles = pkgs.writeShellApplication {
    name = "whisper-subtitles";
    text = builtins.readFile ./scripts/whisper-subtitles.sh;
    runtimeInputs = [
      pkgs.ffmpeg
      whisper
    ];
  };
in
{
  options = {
    pbor.media.audio.whisper.enable = (lib.mkEnableOption "Enable Whisper") // {
      default = false;
    };
    pbor.media.audio.whisper.rocm = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable ROCm or not.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      home.packages = [
        whisper
        whisper-subtitles
      ];
    };
  };
}
