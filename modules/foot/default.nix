{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.foot;
in {
  options = {
    pbor.foot.enable = (lib.mkEnableOption "Enable foot") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    hm = {
      programs.foot = {
        enable = true;
        server.enable = true;

        settings = {
          mouse = {
            hide-when-typing = "yes";
          };

          cursor = with config.lib.stylix.colors; {
            color = "${base00} ${base05}";
          };

          key-bindings = {
            scrollback-down-page = "Control+Shift+f";
            scrollback-down-half-page = "Control+Shift+d";
            scrollback-down-line = "Control+Shift+j";
            scrollback-end = "Control+Shift+e";
            scrollback-up-page = "Control+Shift+b";
            scrollback-up-half-page = "Control+Shift+u";
            scrollback-up-line = "Control+Shift+k";

            clipboard-copy = "Control+Shift+c";
            clipboard-paste = "Control+Shift+v";

            search-start = "Control+Shift+r";
            show-urls-launch = "Control+Shift+o";
            unicode-input = "Control+Shift+i";

            prompt-prev = "Control+Shift+z";
            prompt-next = "Control+Shift+x";
          };
        };
      };
      stylix.targets.foot.enable = true;
    };
  };
}
