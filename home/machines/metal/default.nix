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
    pkgs.tremc
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "gnome3";
  };

  programs.zsh.shellAliases = {
    "reboot-to-windows" = "sudo systemctl reboot --boot-loader-entry auto-window";
  };

  home.sessionVariables = {
    GDK_BACKEND = "wayland";
  };
}
