{ config, lib, pkgs, ... }:

{
  imports = [
    ../../alacritty.nix
    ../../basetools.nix
    ../../devtools.nix
    ../../firefix.nix
    ../../gpg.nix
    ../../git.nix
    ../../neovim.nix
    ../../ssh.nix
    ../../tmux.nix
    ../../zsh.nix
  ];

  home.packages = [
    # AWS
    pkgs.awscli2
    pkgs.saml2aws

    # k8s
    pkgs.docker
    pkgs.kubectl
    pkgs.k9s
    pkgs.stern
  ];

  home.sessionVariables = {
    PATH = "\${HOME}/bin:\${PATH}";
  };
}
