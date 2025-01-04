{config, ...}: {
  pbor.webapps.apps.immich = {
    subDomain = "photos";
    auth.oidc = {
      client_secret = "$pbkdf2-sha512$310000$OKj15ajAukzG787LV5gqBw$p/eN.fDwH/XqCZ0I5/15oGKKOBXS8eAqQLwIfSXidkQgOHIJhhzN224YP7sQauU3MxZRco2gTPxx5N9zozvDbA";
      redirect_uris = [
        "https://photos.${config.pbor.webapps.domain}/auth/login"
        "https://photos.${config.pbor.webapps.domain}/user-settings"
        "app.immich:///oauth-callback"
      ];
      scopes = ["openid" "profile" "email"];
      userinfo_signed_response_alg = "none";
    };
    proxyTo = "http://127.0.0.1:2283";
    locations."/" = {
      custom = {
        extraConfig = ''
          client_max_body_size 1G;
        '';
      };
    };
    dashboard = {
      name = "Photos";
      category = "app";
      icon = "camera";
    };
  };

  services.immich = {
    enable = true;
    host = "127.0.0.1";
    mediaLocation = "/storage/photos";
  };

  systemd.services.immich.unitConfig.RequiresMountsFor = ["/storage"];

  pbor.backup.fsBackups = {
    photos = {
      paths = [
        "/storage/photos"
      ];
    };
  };
}
