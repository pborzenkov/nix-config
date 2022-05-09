{ config, pkgs, ... }:

let
  ssoPort = 8082;
in
{
  imports = [
    ../../../modules/webapps
  ];

  webapps = {
    domain = "lab.borzenkov.net";
    userIDHeader = "X-User";

    ssoSubDomain = "auth";
    ssoInternalAddress = "http://127.0.0.1:${toString ssoPort}";

    acmeDNSProvider = "namecheap";
    acmeCredentialsFile = config.sops.secrets.namecheap-environment.path;

    apps."sso" = {
      subDomain = config.webapps.ssoSubDomain;
      proxyTo = config.webapps.ssoInternalAddress;
      locations."/" = { };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  systemd.services."acme-${config.webapps.domain}".serviceConfig.EnvironmentFile = [
    config.sops.secrets.perfect-privacy-proxy-env.path
  ];

  sops.secrets.perfect-privacy-proxy-env = { };

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
        default_redirect = "https://${config.webapps.domain}";
        hide_mfa_field = true;
        names = {
          simple = "Username / Password";
        };
      };

      cookie = {
        domain = ".${config.webapps.domain}";
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
                regexp = ".*${config.webapps.domain}$";
              }
            ];
            allow = [ "@_authenticated" ];
          }
        ];
      };

      providers = {
        simple = {
          enable_basic_auth = false;
          users = {
            "pavel@borzenkov.net" = "$2y$10$0wBRpG0umcfGOGqouy1lWO7lsZLZCvlMLu4I3Ja0nDMYCEluQl.1a";
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
    namecheap-environment = { };
    nginx-sso-environment = { };
  };
}
