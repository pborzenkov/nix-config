{ config, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      };
    };
  };

  programs.sway = {
    enable = true;
    extraPackages = [ pkgs.wl-clipboard ];
  };
}
