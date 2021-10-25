{ pkgs, modulesPath, ... }:

let
  guide = pkgs.stdenv.mkDerivation {
    name = "yubikey-guide-2021-02-15.html";
    src = pkgs.fetchFromGitHub {
      owner = "drduh";
      repo = "YubiKey-Guide";
      rev = "de29a9e45c285c39bea8706932653d70dfeb9570";
      sha256 = "10f4g6r9s08bc8lmvvx9d0j21mllpf39l30s31jmv3gqgc25a6wv";
    };
    buildInputs = [ pkgs.pandoc ];
    installPhase = ''
      pandoc --highlight-style pygments -s --toc README.md | \
        sed -e 's/<keyid>/\&lt;keyid\&gt;/g' > $out
    '';
  };
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  environment.interactiveShellInit = ''
      export GNUPGHOME=/run/user/$(id -u)/gnupghome
      if [ ! -d $GNUPGHOME ]; then
        mkdir $GNUPGHOME
      fi
      cp ${pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/drduh/config/2703f5992be264e993a46802169a76e7211d9ad0/gpg.conf";
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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    cryptsetup
    pwgen
    midori
    paperkey
    gnupg
    pinentry-curses
    ctmg
  ];

  services.udev.packages = with pkgs; [ yubikey-personalization ];
  services.pcscd.enable = true;

  system.nixos.label = "YubiKey";
  isoImage.isoBaseName = "yubikey";
  isoImage.appendToMenuLabel = " manager";

  # make sure we are air-gapped
  networking.wireless.enable = false;
  networking.dhcpcd.enable = false;

  services.getty.helpLine = "The 'root' account has an empty password.";

  security.sudo.wheelNeedsPassword = false;
  users.users.yubikey = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = "/run/current-system/sw/bin/bash";
  };

  services.xserver = {
    enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "yubikey";
    displayManager.defaultSession = "xfce";
    displayManager.sessionCommands = ''
      ${pkgs.midori}/bin/midori ${guide} &
      ${pkgs.xfce.terminal}/bin/xfce4-terminal &
    '';

    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
}
