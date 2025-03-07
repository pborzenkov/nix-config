{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.devtools.android;
in {
  options = {
    pbor.devtools.android.enable = (lib.mkEnableOption "Enable android") // {default = false;};
  };

  config = lib.mkIf cfg.enable {
    programs.adb.enable = true;
    users.users.pbor.extraGroups = ["adbusers"];

    hm = {config, ...}: {
      home.sessionVariables = {
        ANDROID_USER_HOME = "${config.xdg.configHome}/android";
      };
    };
  };
}
