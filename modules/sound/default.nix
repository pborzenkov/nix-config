{
  config,
  lib,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.sound;
in
{
  options = {
    pbor.sound.enable = (lib.mkEnableOption "Enable sound") // {
      default = config.pbor.enable && isDesktop;
    };
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
    };
  };
}
