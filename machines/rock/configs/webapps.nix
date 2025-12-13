{
  config,
  lib,
  machineSecrets,
  ...
}:
{
  pbor.webapps = {
    enable = true;
    domain = "lab.borzenkov.net";

    ssoSubDomain = "auth";
    ssoInternalAddress = "http://127.0.0.1:9091";

    acmeDNSProvider = "namecheap";
    acmeCredentialsFile = config.age.secrets.namecheap-environment.path;

    apps = {
      sso = {
        subDomain = config.pbor.webapps.ssoSubDomain;
        proxyTo = config.pbor.webapps.ssoInternalAddress;
        locations."/" = { };
        dashboard = {
          name = "Auth";
          category = "infra";
          icon = "lock";
        };
      };
      ldap = {
        subDomain = "ldap";
        proxyTo = "http://127.0.0.1:17170";
        locations."/" = { };
        dashboard = {
          name = "LLDAP";
          category = "infra";
          icon = "key";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  systemd.services."acme-${config.pbor.webapps.domain}".serviceConfig.EnvironmentFile = lib.mkForce [
    config.pbor.webapps.acmeCredentialsFile
    config.age.secrets.gw-proxy-environment.path
  ];

  services = {
    lldap = {
      enable = true;
      environmentFile = config.age.secrets.lldap-environment.path;
      silenceForceUserPassResetWarning = true;
      settings = {
        http_host = "127.0.0.1";
        http_url = "https://ldap.lab.borzenkov.net";
        ldap_base_dn = "dc=borzenkov,dc=net";
        ldap_host = "::";
        ldap_user_dn = "admin";
        ldap_user_email = "admin@borzenkov.net";
        ldap_user_pass_file = "/dev/null"; # set via env var
      };
    };

    authelia.instances.lab = {
      enable = true;
      secrets = {
        manual = true;
        oidcIssuerPrivateKeyFile = config.age.secrets.authelia-jwks-key.path;
      };
      settings = {
        theme = "auto";
        server = {
          address = "tcp://127.0.0.1:9091";
          endpoints.authz.auth-request.implementation = "AuthRequest";
        };
        log = {
          level = "info";
          format = "text";
        };
        totp.disable = true;
        webauthn.disable = true;
        duo_api.disable = true;
        ntp = {
          address = "udp://0.nl.pool.ntp.org:123";
          version = 4;
          max_desync = "3s";
          disable_startup_check = false;
        };
        authentication_backend = {
          password_reset.disable = false;
          refresh_interval = "1m";
          ldap = {
            implementation = "custom";
            address = "ldap://ldap.lab.borzenkov.net:3890";
            start_tls = false;
            base_dn = "dc=borzenkov,dc=net";
            additional_users_dn = "ou=people";
            users_filter = "(&({username_attribute}={input})(objectClass=person))";
            additional_groups_dn = "ou=groups";
            groups_filter = "(member={dn})";
            attributes = {
              display_name = "displayName";
              username = "uid";
              group_name = "cn";
              mail = "mail";
            };

            user = "uid=admin,ou=people,dc=borzenkov,dc=net";
          };
        };
        access_control = {
          default_policy = "deny";
          networks = [
            {
              name = "internal";
              networks = [ "192.168.88.0/24" ];
            }
            {
              name = "vpn";
              networks = [ "192.168.111.0/24" ];
            }
          ];
          rules = lib.mapAttrsToList (_: a: {
            domain = "${a.subDomain}.${config.pbor.webapps.domain}";
            policy = "one_factor";
            subject = a.auth.rbac;
          }) (lib.filterAttrs (_: a: a.auth != null && a.auth.rbac != null) config.pbor.webapps.apps);
        };
        session = {
          cookies = [
            {
              name = "authelia_session";
              domain = config.pbor.webapps.domain;
              authelia_url = "https://${config.pbor.webapps.ssoSubDomain}.${config.pbor.webapps.domain}";
              default_redirection_url = "https://dashboard.${config.pbor.webapps.domain}";
            }
          ];
        };
        storage.local.path = "/var/lib/authelia-lab/db.sqlite3";
        notifier = {
          disable_startup_check = false;
          smtp = {
            address = "submissions://smtp.fastmail.com:465";
            sender = "Authelia <auth@borzenkov.net>";
            subject = "[Authelia] {title}";
            startup_check_address = "auth@borzenkov.net";
            disable_require_tls = false;
            disable_html_emails = true;
            tls.skip_verify = false;
          };
        };
        identity_providers.oidc = {
          authorization_policies = lib.mapAttrs (id: a: {
            default_policy = "deny";
            rules = [
              {
                policy = "one_factor";
                subject = a.auth.oidc.rbac;
              }
            ];
          }) (lib.filterAttrs (_: a: a.auth != null && a.auth.oidc != null) config.pbor.webapps.apps);

          clients = lib.mapAttrsToList (
            id: a:
            {
              client_id = id;
              client_name = id;
              authorization_policy = id;
              public = false;
            }
            // a.auth.oidc.settings
          ) (lib.filterAttrs (_: a: a.auth != null && a.auth.oidc != null) config.pbor.webapps.apps);
        };
      };
    };
  };

  systemd.services.authelia-lab.serviceConfig.EnvironmentFile = [
    config.age.secrets.authelia-environment.path
  ];

  age.secrets = {
    authelia-environment.file = machineSecrets + "/authelia-environment.age";
    authelia-jwks-key = {
      file = machineSecrets + "/authelia-jwks-key.age";
      owner = "authelia-lab";
    };
    namecheap-environment.file = machineSecrets + "/namecheap-environment.age";
    lldap-environment.file = machineSecrets + "/lldap-environment.age";
    gw-proxy-environment.file = machineSecrets + "/gw-proxy-environment.age";
  };

  pbor.backup.fsBackups.lldap = {
    paths = [
      "/var/lib/private/lldap"
    ];
  };
}
