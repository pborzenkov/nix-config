{ config, lib, pkgs, ... }:

{
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../firefox.nix
    ../../foot.nix
    ../../gpg.nix
    ../../git.nix
    ../../neovim.nix
    ../../ssh.nix
    ../../sway.nix
    ../../zsh.nix

    ./sway.nix
  ];

  home.packages = [
    pkgs.tdesktop
    pkgs.calibre
    pkgs.tremc

    pkgs.goldendict
    pkgs.hunspellDicts.en_GB-large
    pkgs.hunspellDicts.nl_NL
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryFlavor = "gnome3";
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
  };
}

