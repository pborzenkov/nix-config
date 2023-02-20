{
  config,
  pkgs,
  ...
}: {
  xdg.configFile.vdirsyncer = {
    text = ''
      [general]
      status_path = "~/.local/state/vdirsyncer"

      [pair borzenkov_net_contacts]
      a = "borzenkov_net_contacts_local"
      b = "borzenkov_net_contacts_remote"
      collections = ["from a", "from b"]

      [storage borzenkov_net_contacts_local]
      type = "filesystem"
      path = "~/.local/share/contacts/borzenkov_net"
      fileext = ".vcf"

      [storage borzenkov_net_contacts_remote]
      type = "carddav"
      url = "https://carddav.fastmail.com/"
      username = "pavel@borzenkov.net"
      password.fetch = ["command", "${pkgs.coreutils}/bin/cat", "/var/run/secrets/fastmail"]

      [pair borzenkov_net_calendar]
      a = "borzenkov_net_calendar_local"
      b = "borzenkov_net_calendar_remote"
      collections = ["from a", "from b"]

      [storage borzenkov_net_calendar_local]
      type = "filesystem"
      path = "~/.local/share/calendar/borzenkov_net"
      fileext = ".ics"

      [storage borzenkov_net_calendar_remote]
      type = "caldav"
      url = "https://caldav.fastmail.com/"
      username = "pavel@borzenkov.net"
      password.fetch = ["command", "${pkgs.coreutils}/bin/cat", "/var/run/secrets/fastmail"]
    '';
    target = "vdirsyncer/config";
  };
  systemd.user = {
    services.vdirsyncer = let
      vdirsyncerScript = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    in {
      Unit = {
        Description = "synchronize calendars and contacts";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${vdirsyncerScript}";
      };
    };
    timers.vdirsyncer = {
      Unit = {
        Description = "synchronize calendars and contacts";
      };
      Timer = {
        OnCalendar = "*:0/10";
        Unit = "vdirsyncer.service";
      };
      Install = {
        WantedBy = ["timers.target"];
      };
    };
  };
}
