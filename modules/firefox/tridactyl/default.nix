{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.firefox.tridactyl;
in
{
  options = {
    pbor.firefox.tridactyl.enable = (lib.mkEnableOption "Enable tridactyl") // {
      default = config.pbor.firefox.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
        programs.firefox.profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          tridactyl
        ];
        home.file.".mozilla/native-messaging-hosts/tridactyl.json" = {
          source = "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts/tridactyl.json";
        };

        xdg.configFile = {
          "tridactyl/tridactylrc".text = ''
            colourscheme base16

            blacklistadd https://rss.lab.borzenkov.net
            blacklistadd https://app.fastmail.com

            bind J tabnext
            bind K tabprev
          '';
          "tridactyl/themes/base16.css".source =
            with config.lib.stylix.colors;
            (pkgs.replaceVars ./base16.css (
              lib.genAttrs (builtins.genList (c: "base0${lib.toHexString c}") 16) (c: "${withHashtag.${c}}")
            ));
        };
      };
  };
}
