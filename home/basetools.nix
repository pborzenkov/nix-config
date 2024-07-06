{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "base16";
      };
      themes = {
        base16 = {
          src = config.scheme inputs.base16-textmate;
        };
      };
      extraPackages = with pkgs.bat-extras; [
        batman
      ];
    };

    fd = {
      enable = true;
    };

    htop = {
      enable = true;
    };

    jq = {
      enable = true;
    };

    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (ext: [ext.pass-otp]);
    };

    ripgrep = {
      enable = true;
      arguments = [
        "--smart-case"
      ];
    };

    skim = {
      enable = true;
      enableFishIntegration = true;

      defaultCommand = "fd --type f";
      fileWidgetCommand = "fd --type f";
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  home.packages = [
    # Search
    pkgs.sd

    # Network
    pkgs.xh
    pkgs.gron
    pkgs.dig
    pkgs.trippy
    pkgs.q

    # Viewers
    pkgs.glow

    # Misc
    pkgs.file
    pkgs.bc
    pkgs.envsubst
    pkgs.zip
    pkgs.unzip
    pkgs.unrar
    pkgs.nur.repos.pborzenkov.osccopy
    pkgs.dtach
    pkgs.dua
    pkgs.usbutils

    # Backups
    pkgs.restic

    # Secrets
    pkgs.sops
  ];

  xdg.configFile = {
    browserpass = {
      text = builtins.toJSON {
        enableOTP = true;
      };
      target = "${config.programs.password-store.settings.PASSWORD_STORE_DIR}/.browserpass.json";
    };
  };

  home.sessionVariables = {
    RESTIC_REPOSITORY = "sftp:zh1012@zh1012.rsync.net:restic";
    RESTIC_PASSWORD_COMMAND = "${pkgs.pass}/bin/pass misc/restic@rsync.net";
  };
}
