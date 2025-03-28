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
            clipboard-copy = "Mod4+c";
            clipboard-paste = "Mod4+v";
          };
        };
      };
      stylix.targets.foot.enable = true;
    };
  };
}
