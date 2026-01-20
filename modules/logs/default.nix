{
  config,
  lib,
  pborlib,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.logs;
in
{
  imports = pborlib.allDirs ./.;

  options = {
    pbor.logs.enable = (lib.mkEnableOption "Enable log collection") // {
      default = !isDesktop;
    };
  };

  config = lib.mkIf cfg.enable {
    services.journald = {
      extraConfig = ''
        SystemMaxUse=100M
      '';
      upload = {
        enable = true;
        settings.Upload = {
          URL = "http://192.168.88.11:9428/insert/journald";
          ServerKeyFile = "-";
          ServerCertificateFile = "-";
          TrustedCertificateFile = "/etc/ssl/certs/ca-certificates.crt";
        };
      };
    };
  };
}
