{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.nix;
in {
  imports = [
    ./sway
  ];

  options = {
    pbor.wm.enable = (lib.mkEnableOption "Enable WM") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.xserver.displayManager.sessionData.desktops}/share/wayland-sessions";
        };
      };
    };
  };
}
