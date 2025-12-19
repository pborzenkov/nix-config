{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.display = {
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

  programs = {
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
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
          "-O"
          "DP-1"
        ];
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
          ${pkgs.dbus}/bin/dbus-run-session gamescope --steam ${builtins.toString cfg.gamescopeSession.args} -- steam ${builtins.toString cfg.gamescopeSession.steamArgs}
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
