{ config, lib, pkgs, ... }:

{
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../filebot.nix
    ../../firefox.nix
    ../../foot.nix
    ../../gpg.nix
    ../../gtk.nix
    ../../git.nix
    ../../helix.nix
    ../../imv.nix
    ../../mpv.nix
    ../../ncmpcpp.nix
    ../../neovim.nix
    ../../rofi.nix
    ../../ssh.nix
    ../../sway.nix
    ../../termshark.nix
    ../../tmux.nix
    ../../zathura.nix
    ../../zsh.nix

    ./mpd.nix
    ./sway.nix
  ];

  home.packages =
    let
      anki = pkgs.writeScriptBin "anki" ''
        export ANKI_WAYLAND=1
        exec ${pkgs.anki-bin}/bin/anki
      '';
    in
    [
      anki
      pkgs.tdesktop
      pkgs.calibre
      pkgs.tremc
      pkgs.virt-manager
      pkgs.libreoffice
      pkgs.jellyfin-media-player
      pkgs.picard
      pkgs.shntool
      pkgs.flac
      pkgs.cuetools

      pkgs.goldendict
      pkgs.hunspellDicts.en_GB-large
      pkgs.hunspellDicts.nl_NL
      pkgs.hunspellDicts.ru_RU

      pkgs.nixos-container
    ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryFlavor = "gnome3";
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    PATH = "\${HOME}/bin:\${PATH}";
  };

  wayland.windowManager.sway.config.window.commands = [
    {
      criteria = { app_id = "org.jellyfin."; };
      command = "inhibit_idle visible";
    }
  ];

  xdg = {
    mimeApps.enable = true;
    configFile.mkctl = {
      target = "mkctl/mkctl.yml";
      text = builtins.toJSON {
        devices = {
          "router" = {
            MAC = "18:fd:74:78:3d:99";
            SSH = {
              password_cmd = [ "${pkgs.pass}/bin/pass" "show" "misc/mikrotik-router" ];
              host_key = ''
                -----BEGIN PUBLIC KEY-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA41mNHUIM4HK1hrUMuYrl
                QzIFmaPbNIpdKxdE5dBxK9P7HjI6nCh2lh1QBWo5mLx6NP3VFbeEjWMbTb94aX1D
                HpOxAmdvIY/ihvBSPJx1Oc31FdHSGnMF7HCaH0XFg3vRozpTHg+7iEed2RaO2gkK
                DgENqRt24xopzO7C8fNSwTX1mlicTjL/Q9GXvNeU+BwRzd7aOvgDIMJZlBN9m8VO
                S4j6ygTFK+mdfn0qN5tk0GlOsRnRNsaRz5uyKZwIf6C0eJmSMKHPpdJqUusshvWh
                fQzlRXz8LhJFcmzBxZ73/2VNLyWgf0V0uM7dJLQR4KwZssFKt3pVxrnhJeFmTwZ1
                LQIDAQAB
                -----END PUBLIC KEY-----
              '';
            };
          };
          "living-room" = {
            MAC = "2c:c8:1b:7b:6b:3b";
            SSH = {
              password_cmd = [ "${pkgs.pass}/bin/pass" "show" "misc/mikrotik-router" ];
              host_key = ''
                -----BEGIN PUBLIC KEY-----
                MIIBIDANBgkqhkiG9w0BAQEFAAOCAQ0AMIIBCAKCAQEAsCIdE1htpX5jsecWL8Yd
                mQ9jl2rxhkFonLe905oyiMIFJsfyeqjssKnEh4tNP7vNsfNebADhTvJ8JQg0rMlP
                0FKT7OXEUoIkqC/cdDqmnHLjvzNrFC2qcNCnOAj7KSNrHFUeJ/2CLrm91BZY1tqE
                /C47aQg8V5O9KaYfLJDnFi+QAUHvg9fldZKpwHfpPJiZdrhJhJ7++PTWv432leZZ
                RzkznGMbhxtjtvbjzSYI4QAm40FBDLKqx5apG8louiaEOWyjro5qbwcTMGQ/Umau
                RBiwfdA7GlzE59MrIjQ6X2FoO5t5AjZRYkijo5XvbQiJDZG7c0zV3/Hq1b1pkyoZ
                zwIBAw==
                -----END PUBLIC KEY-----
              '';
            };
          };
        };
      };
    };
  };
}
