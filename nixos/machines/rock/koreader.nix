{pkgs, ...}: {
  webapps.apps.koreader = {
    subDomain = "koreader";
    proxyTo = "http://127.0.0.1:3131";
    locations."/" = {};
  };

  systemd.services.koreader-syncd = {
    description = "KOReader progress sync server";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "koreader-syncd";
      ExecStart = "${pkgs.nur.repos.pborzenkov.koreader-syncd}/bin/koreader-syncd --address 127.0.0.1:3131 --db /var/lib/koreader-syncd/state.db";
      Restart = "always";
    };
  };
}
