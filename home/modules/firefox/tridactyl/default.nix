{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.firefox.tridactyl;
in {
  options = {
    pbor.firefox.tridactyl.enable = (lib.mkEnableOption "Enable tridactyl") // {default = config.pbor.firefox.enable;};
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.profiles.default.extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      tridactyl
    ];
    home.file.".mozilla/native-messaging-hosts/tridactyl.json" = {
      source = "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts/tridactyl.json";
    };

    xdg.configFile = {
      tridactyl = {
        target = "tridactyl/tridactylrc";
        text = ''
          colourscheme base16

          blacklistadd https://rss.lab.borzenkov.net
          blacklistadd https://app.fastmail.com

          bind J tabnext
          bind K tabprev
        '';
      };
      tridactyl-base16 = {
        target = "tridactyl/themes/base16.css";
        source = with config.lib.stylix.colors.withHashtag; (pkgs.substituteAll {
          src = ./base16.css;
          base00 = "${base00}";
          base01 = "${base01}";
          base02 = "${base02}";
          base03 = "${base03}";
          base04 = "${base04}";
          base05 = "${base05}";
          base06 = "${base06}";
          base07 = "${base07}";
          base08 = "${base08}";
          base09 = "${base09}";
          base0A = "${base0A}";
          base0B = "${base0B}";
          base0C = "${base0C}";
          base0D = "${base0D}";
          base0E = "${base0E}";
          base0F = "${base0F}";
        });
      };
    };
  };
}
