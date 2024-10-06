{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.gpg;
in {
  options = {
    pbor.gpg.enable = (lib.mkEnableOption "Enable gpg") // {default = config.pbor.enable;};
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;

      settings = {
        default-key = "0xB1392A8089E0A994";

        no-autostart = !isDesktop;
      };
    };

    services.gpg-agent = lib.mkIf isDesktop {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    systemd.user.services.gpgconf = lib.mkIf (!isDesktop) {
      Unit = {
        Description = "Create GnuPG socket directory";
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.gnupg}/bin/gpgconf --create-socketdir";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
