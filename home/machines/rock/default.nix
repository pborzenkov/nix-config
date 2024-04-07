{pkgs, ...}: {
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../filebot.nix
    ../../gpg.nix
    ../../git.nix
    ../../helix.nix
    ../../shell.nix
    ../../ssh.nix
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
      WantedBy = ["default.target"];
    };
  };
}
