{pkgs, ...}: {
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
    extraPackages = [
      pkgs.dunst
      pkgs.libnotify

      pkgs.wl-clipboard

      pkgs.xdg-utils
    ];
    extraSessionCommands = ''
      export XDG_SESSION_TYPE="wayland"
      export XDG_SESSION_DESKTOP="wayland"
      export XDG_CURRENT_DESKTOP="wayland"
      export MOZ_ENABLE_WAYLAND="1"
      export NIXOS_OZONE_WL="1"
      export ANKI_WAYLAND="1"

      source ''${HOME}/.nix-profile/etc/profile.d/hm-session-vars.sh
    '';
    wrapperFeatures.gtk = true;
  };
}
