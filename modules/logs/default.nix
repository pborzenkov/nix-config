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
          URL = "https://logs.lab.borzenkov.net:443/insert/journald";
          ServerKeyFile = "-";
          ServerCertificateFile = "-";
          TrustedCertificateFile = "/etc/ssl/certs/ca-certificates.crt";
        };
      };
    };
  };
}
