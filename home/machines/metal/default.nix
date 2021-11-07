{ config, lib, pkgs, ... }:

{
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../firefox.nix
    ../../gpg.nix
    ../../git.nix
    ../../neovim.nix
    ../../ssh.nix
    ../../sway.nix
    ../../zsh.nix
  ];

  home.packages = [
    pkgs.tremc
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "curses";
  };

  programs.zsh.shellAliases = {
    "reboot-to-windows" = "sudo systemctl reboot --boot-loader-entry auto-window";
  };
}
