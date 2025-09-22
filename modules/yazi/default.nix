{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.yazi;
in
{
  options = {
    pbor.yazi.enable = (lib.mkEnableOption "Enable yazi") // {
      default = config.pbor.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        keymap = {
          mgr.prepend_keymap = [
            {
              on = "M";
              run = "plugin mount";
            }
          ];
        };
        settings = {
          open.prepend_rules = [
            {
              name = "**VIDEO_TS/";
              use = [
                "play"
                "reveal"
              ];
            }
          ];
          opener = {
            edit = [
              {
                run = ''hx "$@"'';
                desc = "Edit";
                block = true;
              }
            ];
            play = [
              {
                run = ''mpv --fs "$@"'';
                orphan = true;
              }
            ];
          };
        };
        plugins = {
          mount = pkgs.yaziPlugins.mount;
        };
      };
      stylix.targets.yazi.enable = true;
    };
  };
}
