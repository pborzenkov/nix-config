{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.foot;
in {
  options = {
    pbor.foot.enable = (lib.mkEnableOption "Enable foot") // {default = isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;

      settings = {
        mouse = {
          hide-when-typing = "yes";
        };

        cursor = with config.lib.stylix.colors; {
          color = "${base00} ${base05}";
        };
      };
    };
    stylix.targets.foot.enable = true;
  };
}
