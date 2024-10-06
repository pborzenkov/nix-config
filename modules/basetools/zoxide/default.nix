{
  config,
  lib,
  username,
  ...
}: let
  cfg = config.pbor.basetools.zoxide;
in {
  options = {
    pbor.basetools.zoxide.enable = (lib.mkEnableOption "Enable zoxide") // {default = config.pbor.basetools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
    };
  };
}
