{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.basetools.bitwarden;
in {
  options = {
    pbor.basetools.bitwarden.enable = (lib.mkEnableOption "Enable bitwarden") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {config, ...}: {
      programs.rbw = {
        enable = true;
        settings = {
          base_url = "https://bitwarden.lab.borzenkov.net";
          email = "pavel@borzenkov.net";
          pinentry = pkgs.pinentry-gnome3;
        };
      };
    };
  };
}
