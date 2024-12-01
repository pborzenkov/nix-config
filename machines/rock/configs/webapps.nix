{
  config,
  lib,
  ...
}: let
  ssoPort = 8082;
in {
  pbor.webapps = {
    domain = "lab.borzenkov.net";
    userIDHeader = "X-User";

    ssoSubDomain = "auth";
    ssoInternalAddress = "http://127.0.0.1:${toString ssoPort}";

    acmeDNSProvider = "namecheap";
    acmeCredentialsFile = config.sops.secrets.namecheap-environment.path;

    apps = {
      sso = {
        subDomain = config.pbor.webapps.ssoSubDomain;
        proxyTo = config.pbor.webapps.ssoInternalAddress;
        locations."/" = {};
      };
      ldap = {
        subDomain = "ldap";
        proxyTo = "http://127.0.0.1:17170";
        locations."/" = {};
        dashboard = {
          name = "LLDAP";
          category = "infra";
          icon = "key";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  systemd.services."acme-${config.pbor.webapps.domain}".serviceConfig.EnvironmentFile = lib.mkForce [
    config.pbor.webapps.acmeCredentialsFile
    config.sops.secrets.gw-proxy-environment.path
  ];

  services = {
    lldap = {
      enable = true;
      environmentFile = config.sops.secrets.lldap-environment.path;
      settings = {
        http_host = "127.0.0.1";
        http_url = "https://ldap.lab.borzenkov.net";
        ldap_base_dn = "dc=borzenkov,dc=net";
        ldap_host = "::";
        ldap_user_dn = "admin";
        ldap_user_email = "admin@borzenkov.net";
      };
    };
  };

  services.nginx.sso = {
    enable = true;
    configuration = {
      audit_log = {
        targets = [
          "fd://stdout"
        ];
        events = [
          "access_denied"
          "login_success"
          "login_failure"
          "logout"
          "validate"
        ];
        headers = [
          "x-origin-uri"
          "x-host"
        ];
      };
      login = {
        title = "Login";
        default_method = "simple";
        default_redirect = "https://${config.pbor.webapps.domain}";
        hide_mfa_field = true;
        names = {
          simple = "Username / Password";
        };
      };

      cookie = {
        domain = ".${config.pbor.webapps.domain}";
        expire = 86400;
        prefix = "lab-sso";
        secure = true;
      };

      listen = {
        addr = "127.0.0.1";
        port = ssoPort;
      };

      acl = {
        rule_sets = [
          {
            rules = [
              {
                field = "x-host";
                regexp = ".*${config.pbor.webapps.domain}$";
              }
            ];
            allow = ["@_authenticated"];
          }
        ];
      };

      providers = {
        simple = {
          enable_basic_auth = false;
          users = {
            "pavel@borzenkov.net" = "$2y$10$0wBRpG0umcfGOGqouy1lWO7lsZLZCvlMLu4I3Ja0nDMYCEluQl.1a";
            "pachmu" = "$2a$10$o7yVA5XXTQkOv0KqtllXZOzyUpHvWqVOZUxABDP76MntOydGiTrYa";
          };
        };
      };
    };
  };

  systemd.services.nginx-sso.serviceConfig = {
    EnvironmentFile = [
      config.sops.secrets.nginx-sso-environment.path
    ];
  };

  sops.secrets = {
    gw-proxy-environment = {};
    lldap-environment = {};
    namecheap-environment = {};
    nginx-sso-environment = {};
  };

  pbor.backup.fsBackups.lldap = {
    paths = [
      "/var/lib/lldap"
    ];
  };
}
