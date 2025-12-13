{
  config,
  lib,
  pborlib,
  pkgs,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.wm;

  wofi-settings = pkgs.writeShellApplication {
    name = "wofi-settings";
    text = builtins.readFile ./scripts/settings.sh;
    runtimeInputs = [
      pkgs.wofi
      pkgs.foot
    ];
    runtimeEnv = {
      CONFIGURED_PROVIDERS = ''${builtins.concatStringsSep "," cfg.settings-providers}'';
    };
  };

  wofi-scratch-apps = pkgs.writeShellApplication {
    name = "wofi-scratch-apps";
    text = builtins.readFile ./scripts/scratch-apps.sh;
    runtimeInputs = [
      pkgs.wofi
      pkgs.foot
      pkgs.dtach
    ];
    runtimeEnv = {
      CONFIGURED_APPS = ''${builtins.concatStringsSep "," cfg.scratch-apps}'';
    };
  };

  scratch-term = pkgs.writeShellApplication {
    name = "scratch-term";
    text = builtins.readFile ./scripts/scratch-apps.sh;
    runtimeInputs = [
      pkgs.wofi
      pkgs.foot
      pkgs.dtach
    ];
    runtimeEnv = {
      CONFIGURED_APPS = "fish";
    };
  };

  scratch-yazi = pkgs.writeShellApplication {
    name = "scratch-yazi";
    text = builtins.readFile ./scripts/scratch-apps.sh;
    runtimeInputs = [
      pkgs.wofi
      pkgs.foot
      pkgs.dtach
    ];
    runtimeEnv = {
      CONFIGURED_APPS = "yazi";
    };
  };
in
{
  imports = pborlib.allDirs ./.;

  options = {
    pbor.wm.enable = (lib.mkEnableOption "Enable WM") // {
      default = config.pbor.enable && isDesktop;
    };
    pbor.wm.settings-providers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        An array of setting providers to enable.
      '';
    };
    pbor.wm.scratch-apps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        An array of scratch apps to enable.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        };
      };
    };

    hm =
      { config, ... }:
      {
        home.packages = with pkgs; [
          wev
          wl-clipboard
          xdg-utils
          wofi-settings
          wofi-scratch-apps
          scratch-term
          scratch-yazi
        ];
        programs.zellij.enable = true;
        stylix.targets.zellij.enable = true;

        xdg.configFile."uwsm/env".text = ''
          export MOZ_ENABLE_WAYLAND=1
          export QT_QPA_PLATFORM=wayland
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export NIXOS_OZONE_WL=1
          export SDL_VIDEODRIVER=wayland,x11
          export PROTON_ENABLE_WAYLAND=1
          export PROTON_ENABLE_HDR=1
          export GRIM_DEFAULT_DIR="${config.home.homeDirectory}/down"
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent";
          export PATH="$PATH:$HOME/bin"
        '';
      };
  };
}
