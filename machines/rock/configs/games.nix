{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    display = {
      edid.packages = [
        (pkgs.runCommandLocal "lg-tv-edid" { } ''
          mkdir -p "$out/lib/firmware/edid"
          cp ${inputs.self}/assets/lg-tv.edid "$out/lib/firmware/edid/lg-tv.bin"
        '')
      ];
      outputs."DP-1" = {
        edid = "lg-tv.bin";
        mode = "e";
      };
    };
  };
  users.users.steam = {
    description = "Steam";
    uid = 2000;
    isNormalUser = true;
    home = "/fast-storage/steam";
    createHome = true;
    extraGroups = [
      "gamemode"
      "video"
    ];
  };

  environment.systemPackages = [
    pkgs.mangohud
    pkgs.gamescope-wsi
  ];
  programs = {
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam =
      let
        mangohudConfig = pkgs.writeTextFile {
          name = "mangohud.conf";
          text = ''
            no_display
            gpu_stats
            gpu_temp
            gpu_core_clock
            gpu_power
            cpu_stats
            cpu_temp
            cpu_power
            cpu_mhz
            vram
            ram
            fps
            frametime
            throttling_status
            gamemode
            hdr
            refresh_rate
            toggle_hud=Shift_R+F12
            toggle_preset=Shift_R+F10
          '';
        };
      in
      {
        enable = true;
        extraCompatPackages = [
          pkgs.proton-ge-bin
        ];
        gamescopeSession = {
          enable = true;
          args = [
            "-W"
            "1920"
            "-H"
            "1080"
            "-r"
            "60"
            "--rt"
            "--hdr-enabled"
            "--hdr-itm-enabled"
            "--xwayland-count"
            "2"
            "-O"
            "DP-1"
            "--mangoapp"
          ];
          env = {
            MANGOHUD_CONFIGFILE = "${mangohudConfig}";
            PROTON_ENABLE_HDR = "1";
          };
        };
      };
  };

  boot.kernelModules = [ "uhid" ];
  services = {
    udev.packages = [
      (pkgs.writeTextFile {
        name = "uhid";
        text = ''
          KERNEL=="uhid", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/70-uhid.rules";
      })
    ];
    greetd =
      let
        cfg = config.programs.steam;
        exports = builtins.attrValues (
          builtins.mapAttrs (n: v: "export ${n}=${v}") cfg.gamescopeSession.env
        );
        gamescopeSession = pkgs.writeShellScriptBin "steam-gamescope" ''
          export XDG_CURRENT_DESKTOP="gamescope"
          systemctl --user start steam-session.target
          ${builtins.concatStringsSep "\n" exports}
          ${pkgs.dbus}/bin/dbus-run-session gamescope --steam ${builtins.toString cfg.gamescopeSession.args} -- steam ${builtins.toString cfg.gamescopeSession.steamArgs} 2>&1 | ${pkgs.systemd}/bin/systemd-cat -t gamescope-session
          systemctl --user stop steam-session.target
        '';
      in
      {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
          };
          initial_session = {
            command = "${gamescopeSession}/bin/steam-gamescope";
            user = "steam";
          };
        };
      };
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      applications.apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
      ];
      settings = {
        capture = "kms";
        gamepad = "ds5";
        upnp = "off";
      };
    };
  };
  systemd.user.targets.steam-session = lib.mkIf config.programs.steam.gamescopeSession.enable {
    description = "Steam (gamescope) session";
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
}
