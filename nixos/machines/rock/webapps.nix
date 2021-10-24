{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/webapps
  ];

  webapps = {
    domain = "borzenkov.net";
    userIDHeader = "X-User";
  };
}
