{ config, lib, pkgs, ... }:

{
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../firefox.nix
    ../../foot.nix
    ../../gpg.nix
    ../../gtk.nix
    ../../git.nix
    ../../mpv.nix
    ../../neovim.nix
    ../../rofi.nix
    ../../ssh.nix
    ../../sway.nix
    ../../termshark.nix
    ../../tmux.nix
    ../../zsh.nix

    ./sway.nix
  ];

  home.packages = [
    pkgs.tdesktop
    pkgs.calibre
    pkgs.tremc
    pkgs.virt-manager

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
    PATH = "\${HOME}/bin:\${PATH}";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.arc-theme;
      name = "Arc";
    };
  };
}
