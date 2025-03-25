{
  pkgs,
  inputs,
  ...
}: let
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
in {
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
      extraPackages = [
        pkgs.gamemode
      ];
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };
  };
  environment.systemPackages = [in-gamescope];
  users.users.pbor.extraGroups = ["gamemode"];

  boot.kernelModules = ["uhid"];
  services = {
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-cpp;
      extraRules = [
        {
          name = "gamescope";
          nice = -20;
          sched = "rr";
        }
      ];
    };
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      applications.apps = [
        {
          name = "Steam";
          output = "/tmp/sunshine-steam.txt";
          cmd = "in-gamescope -e -- capsh --noamb -+ steam -tenfoot";
          prep-cmd = let
            output-name = "HDMI-A-1";
            do-sunshine-monitor = pkgs.writeShellApplication {
              name = "do-sunshine-monitor";
              text = ''
                hyprctl keyword workspace name:sunshine, monitor:${output-name}
                hyprctl keyword monitor ${output-name}, 3840x2160, 1920x0, 2
                hyprctl keyword windowrulev2 workspace name:sunshine, class:gamescope
                sudo dd of=/sys/kernel/debug/dri/1/${output-name}/edid_override if=${inputs.self}/assets/lg-tv.edid
                echo on | sudo dd of=/sys/kernel/debug/dri/1/${output-name}/force
                echo 1 | sudo dd of=/sys/kernel/debug/dri/1/${output-name}/trigger_hotplug
              '';
              runtimeInputs = [pkgs.hyprland];
            };
            undo-sunshine-monitor = pkgs.writeShellApplication {
              name = "undo-sunshine-monitor";
              text = ''
                hyprctl keyword monitor ${output-name},disable
                echo off | sudo dd of=/sys/kernel/debug/dri/1/${output-name}/force
                echo 1 | sudo dd of=/sys/kernel/debug/dri/1/${output-name}/trigger_hotplug
                hyprctl reload
              '';
              runtimeInputs = [pkgs.hyprland];
            };
          in [
            {
              do = "${do-sunshine-monitor}/bin/do-sunshine-monitor";
              undo = "${undo-sunshine-monitor}/bin/undo-sunshine-monitor";
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
  };
  users.users.pbor.openssh.authorizedKeys.keys = [
    ''command="unlock-hyprlock",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICODVIFG+5OjXWBvSVxgKVDV4zce/BMLX7P0b4POblhp u0_a224@localhost''
  ];
}
