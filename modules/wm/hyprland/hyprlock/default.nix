{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.wm.hyprland.hyprlock;

  unlock-hyprlock = pkgs.writeShellApplication {
    name = "unlock-hyprlock";
    text = ''
      pkill -SIGUSR1 hyprlock
    '';
    runtimeInputs = [ pkgs.procps ];
  };
in
{
  options = {
    pbor.wm.hyprland.hyprlock.enable = (lib.mkEnableOption "Enable hyprlock") // {
      default = config.pbor.wm.hyprland.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.hyprlock = { };
    environment.systemPackages = [ unlock-hyprlock ];

    hm = {
      programs.hyprlock = {
        enable = true;
        settings = {
          animations.enabled = false;
          input-field = {
            fade_on_empty = false;
          };
          background = {
            blur_passes = 2;
          };
        };
      };
      stylix.targets.hyprlock.enable = true;
    };
  };
}
