{ config, pkgs, lib, ... }:

{
  programs.gpg = {
    enable = true;

    settings = {
      default-key = "0xB1392A8089E0A994";
    };
    scdaemonSettings = {
      disable-ccid = lib.mkIf pkgs.stdenv.isDarwin true;
    };
  };
}
