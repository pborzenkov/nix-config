{ config, pkgs, ... }:

let
  sway-run = pkgs.writeShellScriptBin "sway-run" ''
    export XDG_SESSION_TYPE=wayland;
    export XDG_SESSION_DESKTOP=wayland;
    export XDG_CURRENT_DESKTOP=wayland;

    source ''${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh

    systemd-cat --identifier=sway sway $@
  '';
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${sway-run}/bin/sway-run";
      };
    };
  };

  programs.sway = {
    enable = true;
    extraPackages = [
      pkgs.dunst
      pkgs.libnotify

      pkgs.wl-clipboard

      pkgs.xdg-utils
    ];
  };
}

