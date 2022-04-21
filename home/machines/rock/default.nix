{ config, lib, pkgs, ... }:

{
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../gpg.nix
    ../../git.nix
    ../../neovim.nix
    ../../ssh.nix
    ../../zsh.nix
  ];

  programs.gpg.settings = {
    no-autostart = true;
  };

  systemd.user.services.gpgconf = {
    Unit = {
      Description = "Create GnuPG socket directory";
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.gnupg}/bin/gpgconf --create-socketdir";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
