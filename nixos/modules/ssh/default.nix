{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.ssh;
in {
  options = {
    pbor.ssh.enable = (lib.mkEnableOption "Enable ssh") // {default = config.pbor.enable && !isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
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
