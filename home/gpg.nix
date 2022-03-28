{ config, pkgs, ... }:

{
  programs.gpg = {
    enable = true;

    settings = {
      default-key = "0xB1392A8089E0A994";
    };
    scdaemonSettings = {
      disable-ccid = if pkgs.stdenv.isDarwin then true else null;
    };
  };
}
