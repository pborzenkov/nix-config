{
  config,
  pkgs,
  ...
}: {
  services.vdirsyncer = {
    enable = true;
    jobs = {
      "borzenkov.net" = {
        enable = true;
        additionalGroups = [config.users.groups.keys.name];
        forceDiscover = true;
        config = {
          pairs = {
            borzenkov_net_contacts = {
              a = "borzenkov_net_contacts_local";
              b = "borzenkov_net_contacts_remote";
              collections = ["from b"];
            };
            borzenkov_net_calendar = {
              a = "borzenkov_net_calendar_local";
              b = "borzenkov_net_calendar_remote";
              collections = ["from b"];
            };
          };

          storages = {
            borzenkov_net_contacts_local = {
              type = "filesystem";
              path = "/var/lib/vdirsyncer/borzenkov.net/contacts";
              fileext = ".vcf";
            };
            borzenkov_net_contacts_remote = {
              type = "carddav";
              url = "https://carddav.fastmail.com/";
              username = "pavel@borzenkov.net";
              "password.fetch" = ["command" "${pkgs.coreutils}/bin/cat" "${config.sops.secrets.fastmail.path}"];
              read_only = true;
            };

            borzenkov_net_calendar_local = {
              type = "filesystem";
              path = "/var/lib/vdirsyncer/borzenkov.net/calendar";
              fileext = ".ics";
            };
            borzenkov_net_calendar_remote = {
              type = "caldav";
              url = "https://caldav.fastmail.com/";
              username = "pavel@borzenkov.net";
              "password.fetch" = ["command" "${pkgs.coreutils}/bin/cat" "${config.sops.secrets.fastmail.path}"];
              read_only = true;
            };
          };
        };
      };
    };
  };

  pbor.backup.fsBackups.pim = {
    paths = [
      "/var/lib/vdirsyncer/borzenkov.net/contacts"
      "/var/lib/vdirsyncer/borzenkov.net/calendar"
    ];
  };

  sops.secrets.fastmail = {
    mode = "0440";
    group = config.users.groups.keys.name;
  };
}
