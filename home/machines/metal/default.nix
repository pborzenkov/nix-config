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

  xdg.configFile.mkctl = {
    target = "mkctl/mkctl.yml";
    text = builtins.toJSON {
      devices = {
        "router" = {
          MAC = "dc:2c:6e:14:4b:a9";
          SSH = {
            password_cmd = [ "${pkgs.pass}/bin/pass" "show" "misc/mikrotik-router" ];
            host_key = ''
              -----BEGIN PUBLIC KEY-----
              MIIBIDANBgkqhkiG9w0BAQEFAAOCAQ0AMIIBCAKCAQEArpkjCh6iQUMS8pG2YDm3
              rEoKah27ZIuckWcIwsVigvYgCByVFrI3ZESbW9IpKFE1on8tV6xk6xqy9YqY3PKb
              NPD2CtgPVgQ9ZIjvZ6DodYhYqoK0e5mWMeANrrzhfjUUrE+8mb9g1XKc5Js1YKBA
              x7/hL+iYCRrqAFO7p+I16qj7OWZRJSGttHhoYrTjxpVgf3DFjfpv47ZmsZcqwClg
              1OMydlGbMaWCEV6DAzqP3xG1b49C4NsDRm9frxNzAtv0bj9Vb5BKOejd8rlAVD9p
              ZewPYMr7G3GGy+9b8oHB6rdXyz73VLIKjA0UcOYq0MlKSRMYE9iODqdlj/0ruu1e
              SwIBAw==
              -----END PUBLIC KEY-----
            '';
          };
        };
        "study-room" = {
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
        "living-room" = {
          MAC = "cc:2d:e0:c2:cf:12";
          SSH = {
            password_cmd = [ "${pkgs.pass}/bin/pass" "show" "misc/mikrotik-router" ];
            host_key = ''
              -----BEGIN PUBLIC KEY-----
              MIIBIDANBgkqhkiG9w0BAQEFAAOCAQ0AMIIBCAKCAQEA0/AZwu6Wh9wPHzogtnys
              uDt6y3SLJZPMBK9BVQQbALdrh++CuJXOmeUycSqDTsM8ROm9K4BbDpngeE17TTy/
              xMtdmbRHQBewsLgPV8HlgOsMpPvPgtEEtFplALiGN3Pzer23dXDKDMu0WRa2bKqd
              ONtMh0uaTrDhGu/VGVZqGVMBGvwtI8+eMm6ch2S7J7N2YmyyhsDEKTy41pdjJNe5
              7SLAPHlneZOwmUTU2wYgtLursUKBUy5GJiYVH/XlrHphdIaWvfE/NCv1eIMzNS/G
              IzCCP/hRPTw29/Bh68ZErBlZhpvxr2Wcw6evbY1zANO2A2Eros5uOpI4szsjquSn
              swIBAw==
              -----END PUBLIC KEY-----
            '';
          };
        };
        "bedroom" = {
          MAC = "2c:c8:1b:14:03:a4";
          SSH = {
            password_cmd = [ "${pkgs.pass}/bin/pass" "show" "misc/mikrotik-router" ];
            host_key = ''
              -----BEGIN PUBLIC KEY-----
              MIIBIDANBgkqhkiG9w0BAQEFAAOCAQ0AMIIBCAKCAQEAy0RoLg8mhgvsLcQtj8mA
              m5FCQGWhneZri6oRXthLwbqFPJli3mGljTIYiK6B5s5EN/kPBtI0WzEoM14Le3go
              86xSkHg6JsoDkTY5+eoC093035EcC+gFBRgWs3dlp9b7il9VORpFvb3koKopVwxu
              Rwdzb22VVfekNN9WzkpkOQbRc8O/hxA8PChVtCNpLUVuh6mzgm4FlZTJZ5qngVQe
              nfIEKQdLc0lZSc4bD8xsfdgWa95/6zOINUGsXxqP1m8KPnG6akcBBmF92Rvyl18/
              kEZ3dUCrluZizIQENu5DZe6ZIxoRITfNFm/yBYMBlOD87HtK1XsmKgXu06b467rI
              uQIBAw==
              -----END PUBLIC KEY-----
            '';
          };
        };
      };
    };
  };
}
