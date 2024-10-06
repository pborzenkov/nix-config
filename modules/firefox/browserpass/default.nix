{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.firefox.browserpass;
in {
  options = {
    pbor.firefox.browserpass.enable = (lib.mkEnableOption "Enable browserpass") // {default = config.pbor.firefox.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      osConfig,
      config,
      ...
    }: {
      programs = {
        firefox.profiles.default.extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          browserpass
        ];
        browserpass = {
          enable = true;
          browsers = ["firefox"];
        };
      };

      home.file.".browserpass.json" = lib.mkIf osConfig.pbor.basetools.pass.enable {
        text = builtins.toJSON {
          enableOTP = true;
        };
        target = "${config.programs.password-store.settings.PASSWORD_STORE_DIR}/.browserpass.json";
      };
    };
  };
}
