{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.gpg = {
    enable = true;

    settings = {
      default-key = "0xB1392A8089E0A994";
    };
    scdaemonSettings = lib.optionalAttrs pkgs.stdenv.isDarwin {
      disable-ccid = true;
      reader-port = "Yubico YubiKey OTP+FIDO+CCID";
    };
  };
}
