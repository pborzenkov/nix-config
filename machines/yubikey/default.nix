{
  pkgs,
  lib,
  ...
}: let
  guide = pkgs.stdenv.mkDerivation {
    name = "yubikey-guide-2024-08-18.html";
    src = pkgs.fetchFromGitHub {
      owner = "drduh";
      repo = "YubiKey-Guide";
      rev = "e218607c1f7c7573860f7e4d7bfd8ba1f8266736";
      sha256 = "sha256-f9jHcgMdoPF4Pu2IdxnUoSG62XJpqyRXf+gCIg4dYkk=";
    };
    buildInputs = [pkgs.pandoc];
    installPhase = ''
      pandoc --highlight-style pygments -s --toc README.md | \
        sed -e 's/<keyid>/\&lt;keyid\&gt;/g' > $out
    '';
  };
  gpg-conf = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/drduh/config/eedb4ecf4bb2b5fd71bb27768f76da0f2e2605c8/gpg.conf";
    sha256 = "sha256-jMo0AGa3lXlLAjCi61LvyW9WvJxJBVlRV9p1yIRv1lo=";
  };
  gpg-agent-conf = pkgs.writeTextFile {
    name = "gpg-agent.conf";
    text = ''
      pinentry-program /run/current-system/sw/bin/pinentry-curses
    '';
  };
  yubikey-shell = pkgs.writeScriptBin "yubikey-shell" ''
    ${pkgs.tmux}/bin/tmux new-session -s "yubikey" -d
    ${pkgs.tmux}/bin/tmux split-window -h ${pkgs.w3m}/bin/w3m ${guide}
    ${pkgs.tmux}/bin/tmux select-pane -t 0
    ${pkgs.tmux}/bin/tmux attach-session -d
  '';
in {
  boot = {
    supportedFilesystems = lib.mkForce ["vfat"];
  };
  system.nixos.label = "YubiKey";
  isoImage = {
    isoBaseName = "yubikey";
    appendToMenuLabel = " manager";
  };

  environment = {
    interactiveShellInit = ''
      export GNUPGHOME=/run/user/$(id -u)/gnupghome
      if [ -d $GNUPGHOME ]; then
        return
      fi

      mkdir $GNUPGHOME
      cp ${gpg-conf} "$GNUPGHOME/gpg.conf"
      cp ${gpg-agent-conf} "$GNUPGHOME/gpg-agent.conf"
      echo "\$GNUPGHOME has been set up for you. Generated keys will be in $GNUPGHOME."
    '';

    systemPackages = with pkgs; [
      yubikey-personalization
      yubikey-manager
      global-platform-pro
      cryptsetup
      pwgen
      paperkey
      gnupg
      pinentry-curses
      ctmg
      yubikey-shell
    ];
  };

  pbor.enable = false;
  nix.enable = false;

  services = {
    udev.packages = with pkgs; [yubikey-personalization];
    pcscd.enable = true;
  };

  networking = {
    wireless.enable = false;
    dhcpcd.enable = false;
  };

  security.sudo.wheelNeedsPassword = false;
  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = "/run/current-system/sw/bin/bash";
  };
  services.getty = {
    autologinUser = lib.mkForce "yubikey";
    helpLine = lib.mkForce "Run yubikey-shell to start tmux with shell and YubiKey Guide.";
  };
}
