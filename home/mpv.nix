{ config, pkgs, ... }:

{
  systemd.user.services.jellyfin-mpv-shim = {
    Unit = {
      Description = "Jellyfin MPV shim";
      PartOf = [ "sway-session.target" ];
      After = [ "sway-session.target" ];
    };

    Service = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "1sec";
      ExecStart = "${pkgs.jellyfin-mpv-shim}/bin/jellyfin-mpv-shim";
    };

    Install.WantedBy = [ "sway-session.target" ];
  };

  xdg.configFile =
    let
      conf = ''
        alang=eng,en,English
        slang=eng,en,English
      '';
    in
    {
      jellyfin-mpv-shim-mpv-conf = {
        target = "jellyfin-mpv-shim/mpv.conf";
        text = conf;
      };
      mpv-conf = {
        target = "mpv/mpv.conf";
        text = conf;
      };
    };
}
