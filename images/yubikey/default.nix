{ config, pkgs, lib, modulesPath, ... }:

let
  guide = pkgs.stdenv.mkDerivation {
    name = "yubikey-guide-2021-10-24.html";
    src = pkgs.fetchFromGitHub {
      owner = "drduh";
      repo = "YubiKey-Guide";
      rev = "fe6434577bce964aefd33d5e085d6ac0008e17ce";
      sha256 = "sha256-HQrS2+yvSXi/XCOzWRIV4S/riKpCvnHTSGZfbYXEmrg=";
    };
    buildInputs = [ pkgs.pandoc ];
    installPhase = ''
      pandoc --highlight-style pygments -s --toc README.md | \
        sed -e 's/<keyid>/\&lt;keyid\&gt;/g' > $out
    '';
  };

  yubikey-shell = pkgs.writeScriptBin "yubikey-shell" ''
    ${pkgs.tmux}/bin/tmux new-session -s "yubikey" -d
    ${pkgs.tmux}/bin/tmux split-window -h ${pkgs.w3m}/bin/w3m ${guide}
    ${pkgs.tmux}/bin/tmux select-pane -t 0
    ${pkgs.tmux}/bin/tmux attach-session -d
  '';
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel.nix")
  ];

  environment.interactiveShellInit = ''
      export GNUPGHOME=/run/user/$(id -u)/gnupghome
      if [ -d $GNUPGHOME ]; then
        return
      fi

      mkdir $GNUPGHOME
      cp ${pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/drduh/config/2334d3d1d058d9d16ca797f49740643f793303ed/gpg.conf";
      sha256 = "0va62sgnah8rjgp4m6zygs4z9gbpmqvq9m3x4byywk1dha6nvvaj";
    }} "$GNUPGHOME/gpg.conf"
        cp ${pkgs.writeTextFile {
      name = "gpg-agent.conf";
      text = ''
        pinentry-program /run/current-system/sw/bin/pinentry-curses
      '';
    }} "$GNUPGHOME/gpg-agent.conf"
      echo "\$GNUPGHOME has been set up for you. Generated keys will be in $GNUPGHOME."
  '';

  boot = {
    supportedFilesystems = lib.mkForce [ "vfat" ];
  };

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    yubikey-manager
    cryptsetup
    pwgen
    midori
    paperkey
    gnupg
    pinentry-curses
    ctmg
    yubikey-shell
  ];

  services.udev.packages = with pkgs; [ yubikey-personalization ];
  services.pcscd.enable = true;

  system.nixos.label = "YubiKey";
  isoImage.isoBaseName = "yubikey";
  isoImage.appendToMenuLabel = " manager";

  # make sure we are air-gapped
  networking.wireless.enable = false;
  networking.dhcpcd.enable = false;

  security.sudo.wheelNeedsPassword = false;
  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = "/run/current-system/sw/bin/bash";
  };
  services.getty = {
    autologinUser = lib.mkForce "yubikey";
    helpLine = lib.mkForce "Run yubikey-shell to start tmux with shell and YubiKey Guide.";
  };
}
