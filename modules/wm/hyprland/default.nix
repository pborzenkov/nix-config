{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}: let
  cfg = config.pbor.wm.hyprland;
in {
  imports = pborlib.allDirs ./.;

  options = {
    pbor.wm.hyprland.enable = (lib.mkEnableOption "Enable Hyprland") // {default = config.pbor.wm.enable;};
    pbor.wm.hyprland.monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        An array that configures monitors.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    hm = {config, ...}: {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;

        plugins = [
          pkgs.hyprlandPlugins.hy3
        ];

        settings = {
          "$mod" = "Super";

          bind = [
            "$mod, Return, exec, foot"
            "$mod, d, exec, wofi -S run"
            "$mod+Shift, s, exec, wofi-power-menu"
          ];

          monitor = cfg.monitors;
        };
      };
      stylix.targets.hyprland.enable = true;
    };
  };
}
