{ pkgs, ... }:
let
  in-gamescope = pkgs.writeShellApplication {
    name = "in-gamescope";
    text = ''
      GAMESCOPE_OPTS=()

      while [[ $# -gt 0 ]]; do
        if [ "$1" == "--" ]; then
          shift
          break
        fi
        GAMESCOPE_OPTS+=("$1")
        shift
      done

      IN_GAMESCOPE="''${GAMESCOPE_WAYLAND_DISPLAY:-}"
      if [ -z "''${IN_GAMESCOPE}" ]; then
        exec gamescope "''${GAMESCOPE_OPTS[@]}" -- "$@"
      fi

      exec "$@"
    '';
  };
in
{
  boot.kernelModules = [ "ntsync" ];
  services = {
    udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync";
        text = ''
          KERNEL=="ntsync", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/70-ntsync.rules";
      })
    ];
  };
  programs = {
    gamescope = {
      enable = true;
      args = [
        "-W"
        "3840"
        "-H"
        "2160"
        "-w"
        "3840"
        "-h"
        "2160"
        "-r"
        "60"
        "--rt"
        "--hdr-enabled"
        "--backend"
        "wayland"
        "--fullscreen"
        "--force-grab-cursor"
        "-s"
        "2"
      ];
    };
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          STEAM_FORCE_DESKTOPUI_SCALING = "2.0";
        };
      };
      extraPackages = [
        pkgs.gamemode
      ];
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };
  };
  environment.systemPackages = [
    in-gamescope
    pkgs.lutris
  ];
  users.users.pbor.extraGroups = [ "gamemode" ];
}
