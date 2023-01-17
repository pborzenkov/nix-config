{
  config,
  pkgs,
  ...
}: {
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
}
