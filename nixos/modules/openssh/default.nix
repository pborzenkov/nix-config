{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.openssh;
in {
  options = {
    pbor.openssh.enable = (lib.mkEnableOption "Enable openssh") // {default = config.pbor.enable && !isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        LogLevel = "INFO";
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };

      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
    };
  };
}
