{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../git.nix
    ../../helix.nix
    ../../ssh.nix
    ../../tmux.nix
    ../../zsh.nix
  ];
}
