{ config, lib, pkgs, ... }:
let
  webapps = rec {
    baseDomain = "borzenkov.net";

    userIDHeader = "X-User";

    vhostWithSSL = vhost: lib.recursiveUpdate
      {
        forceSSL = true;
        useACMEHost = baseDomain;
      }
      vhost;

    vhostWithAuth = vhost: lib.recursiveUpdate
      {
        locations = {
          "/auth" = {
            proxyPass = "${ssoInternalAddress}/auth";
            extraConfig = ''
              internal;
 
              proxy_pass_request_body off;
              proxy_set_header Content-Length "";

              proxy_set_header X-Host $http_host;
              proxy_set_header X-Origin-URI $request_uri;
            '';
          };

          "@error401" = {
            return = "302 https://${authDomain}/login?go=$scheme://$http_host$request_uri";
          };
        };
      }
      (vhostWithSSL vhost);

    locationWithAuth = location: lib.recursiveUpdate
      {
        extraConfig = ''
          auth_request /auth;
          error_page 401 = @error401;

          auth_request_set $cookie $upstream_http_set_cookie;
          add_header Set-Cookie $cookie;
          auth_request_set $username $upstream_http_x_username;
          proxy_set_header ${userIDHeader} $username;
        '';
      }
      location;
  };

  authDomain = "auth.${webapps.baseDomain}";

  ssoPort = 8082;
  ssoInternalAddress = "http://127.0.0.1:${toString ssoPort}";
in
{
  security.acme = {
    acceptTerms = true;
    email = "pavel@borzenkov.net";
    certs."${webapps.baseDomain}" = {
      extraDomainNames = [ "*.${webapps.baseDomain}" ];
      dnsProvider = "namecheap";
      credentialsFile = config.sops.secrets.namecheap-environment.path;
      dnsPropagationCheck = true;
      group = config.users.users.nginx.group;
    };
  };

  systemd.services."acme-borzenkov.net".after = [ "network-online.target" ];

  sops.secrets.namecheap-environment = {};

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."${webapps.baseDomain}" = webapps.vhostWithSSL {
      default = true;
      locations."/".return = "404";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

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
        default_redirect = "https://${webapps.baseDomain}";
        hide_mfa_field = true;
        names = {
          simple = "Username / Password";
        };
      };

      cookie = {
        domain = ".${webapps.baseDomain}";
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
                regexp = ".*${webapps.baseDomain}$";
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

  sops.secrets.nginx-sso-environment = {};

  services.nginx.virtualHosts."auth.${webapps.baseDomain}" = webapps.vhostWithSSL {
    locations."/".proxyPass = "${ssoInternalAddress}/";
  };

  imports = [
    (import ./webapps/grafana.nix { inherit config pkgs webapps; })
    (import ./webapps/miniflux.nix { inherit config pkgs webapps; })
    (import ./webapps/photoprism.nix { inherit config pkgs webapps; })
  ];
}
