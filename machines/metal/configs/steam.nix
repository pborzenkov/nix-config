{pkgs, ...}: let
  with-gamescope = pkgs.writeShellApplication {
    name = "with-gamescope";
    text = ''
      GAMESCOPE_OPTS=()
      STEAM="0"

      while [[ $# -gt 0 ]]; do
        if [ "$1" == "--" ]; then
          shift
          break
        fi
        if [ "$1" = "-e" ] || [ "$1" = "--steam" ]; then
          STEAM="1"
        fi
        GAMESCOPE_OPTS+=("$1")
        shift
      done

      if [ "$STEAM" = 1 ]; then
        exec gamescope "''${GAMESCOPE_OPTS[@]}" -- "$@"
      fi

      gamescope "''${GAMESCOPE_OPTS[@]}" &
      GAMESCOPE_PID=$!

      "$@"
      kill $GAMESCOPE_PID
    '';
  };

  steamscope = pkgs.writeShellApplication {
    name = "steamscope";
    text = ''
      exec with-gamescope -- steam
    '';
  };
in {
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
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
      ];
    };
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraPackages = [
        pkgs.gamemode
      ];
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };
  };
  environment.systemPackages = [with-gamescope steamscope];

  boot.kernelModules = ["uhid"];
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    applications.apps = [
      {
        name = "Steam";
        output = "/tmp/sunshine-steam.txt";
        cmd = "with-gamescope -e -- steam -tenfoot";
        prep-cmd = [
          {
            do = "hyprctl keyword windowrulev2 workspace name:sunshine, class:gamescope";
            undo = "hyprctl reload";
          }
        ];
        image-path = "steam.png";
      }
    ];
    settings = {
      capture = "kms";
      gamepad = "ds5";
      upnp = "off";
      output_name = "0";
    };
  };
  users.users.pbor.openssh.authorizedKeys.keys = [
    ''command="unlock-hyprlock",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICODVIFG+5OjXWBvSVxgKVDV4zce/BMLX7P0b4POblhp u0_a224@localhost''
  ];
}
