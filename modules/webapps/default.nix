{ config, lib, pkgs, ... }:

{
  options.webapps = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = ''
        Base domain for web applications.
      '';
      example = "borzenkov.net";
    };

    userIDHeader = lib.mkOption {
      type = lib.types.str;
      description = ''
        HTTP header with the name of the authenticated user.
      '';
      example = "X-User";
    };

    ssoSubDomain = lib.mkOption {
      type = lib.types.str;
      description = ''
        Subdomain of the SSO service.
      '';
      example = "auth";
    };
    ssoInternalAddress = lib.mkOption {
      type = lib.types.str;
      description = ''
        Internal address of the SSO service.
      '';
      example = "http://192.168.1.10:8082";
    };

    acmeDNSProvider = lib.mkOption {
      type = lib.types.str;
      description = ''
        ACME DNS challenge provider.
      '';
      example = "namecheap";
    };

    acmeCredentialsFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to ACME credentials file.
      '';
      example = "/var/run/secretes/acme";
    };

    apps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          subDomain = lib.mkOption {
            type = lib.types.str;
            description = ''
              'Subdomain of the web application.
            '';
            example = "grafana";
          };
          proxyTo = lib.mkOption {
            type = lib.types.str;
            description = ''
              Proxy requests to this backend.
            '';
            example = "192.168.1.10:1234";
          };
          locations = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                auth = lib.mkOption {
                  type = lib.types.bool;
                  description = ''
                    Enabled authentication for the location.
                  '';
                  default = false;
                  example = true;
                };
                custom = lib.mkOption {
                  type = lib.types.nullOr lib.types.attrs;
                  description = ''
                    Custom config merged into the location config.
                  '';
                  default = null;
                  example =
                    {
                      proxyWebsockets = true;
                    };
                };
              };
            });
          };
        };
      });
      description = ''
        Defines a web application.
      '';
      default = { };
    };
  };

  config =
    let
      cfg = config.webapps;
    in
    {
      security.acme = {
        acceptTerms = true;
        email = "pavel@borzenkov.net";
        certs."${cfg.domain}" = {
          extraDomainNames = [ "*.${cfg.domain}" ];
          dnsProvider = cfg.acmeDNSProvider;
          credentialsFile = cfg.acmeCredentialsFile;
          dnsPropagationCheck = true;
          group = config.users.users.nginx.group;
        };
      };
      systemd.services."acme-${cfg.domain}".after = [ "network-online.target" ];

      services.nginx = {
        enable = true;

        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        virtualHosts = {
          "${cfg.domain}" = {
            default = true;
            locations."/".return = "404";
            forceSSL = true;
            useACMEHost = cfg.domain;
          };
        } // lib.mapAttrs'
          (vhostName: vhostConfig: lib.nameValuePair ("${vhostConfig.subDomain}.${cfg.domain}") (
            let
              needAuth = lib.any (x: x) (lib.mapAttrsToList (locName: locConfig: locConfig.auth) vhostConfig.locations);
            in
            {
              forceSSL = true;
              useACMEHost = cfg.domain;
              locations = (lib.mapAttrs
                (locName: locConfig: ({
                  proxyPass = "${vhostConfig.proxyTo}$request_uri";
                  extraConfig = lib.optionalString locConfig.auth ''
                    auth_request /auth;
                    error_page 401 = @error401;

                    auth_request_set $cookie $upstream_http_set_cookie;
                    add_header Set-Cookie $cookie;
                    auth_request_set $username $upstream_http_x_username;
                    proxy_set_header ${cfg.userIDHeader} $username;
                  '';
                } // lib.optionalAttrs (locConfig.custom != null) locConfig.custom))
                vhostConfig.locations) // lib.optionalAttrs needAuth {
                "/auth" = {
                  proxyPass = "${cfg.ssoInternalAddress}/auth";
                  extraConfig = ''
                    internal;

                    proxy_pass_request_body off;
                    proxy_set_header Content-Length "";

                    proxy_set_header X-Host $http_host;
                    proxy_set_header X-Origin-URI $request_uri;
                  '';
                };

                "@error401" = {
                  return = "302 https://${cfg.ssoSubDomain}.${cfg.domain}/login?go=$scheme://$http_host$request_uri";
                };
              };
            }
          )
          )
          cfg.apps;
      };
    };
}
