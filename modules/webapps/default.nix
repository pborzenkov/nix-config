{
  config,
  lib,
  ...
}: {
  options.webapps = {
    domain = lib.mkOption {
      type = lib.types.str;
      description = ''
        Base domain for web applications.
      '';
      example = "borzenkov.net";
    };
    subDomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Additional sub-domains for wildcard certificate.
      '';
      example = "lab.borzenkov.net";
      default = [];
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

    dashboardCategories = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = ''
              Category name.
            '';
            example = "Applications";
          };
          tag = lib.mkOption {
            type = lib.types.str;
            description = ''
              Category tag.
            '';
            example = "app";
          };
        };
      });
      description = ''
        App categories to display on the dashboard.
      '';
      example = [
        {
          name = "Application";
          tag = "app";
        }
      ];
      default = [];
    };

    apps = lib.mkOption {
      type =
        lib.types.attrsOf
        (lib.types.submodule {
          options = {
            subDomain = lib.mkOption {
              type = lib.types.str;
              description = ''
                'Subdomain of the web application.
              '';
              example = "grafana";
            };
            proxyTo = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                Proxy requests to this backend.
              '';
              example = "192.168.1.10:1234";
              default = null;
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
                    example = {
                      proxyWebsockets = true;
                    };
                  };
                };
              });
            };
            custom = lib.mkOption {
              type = lib.types.nullOr lib.types.attrs;
              description = ''
                Custom config merged into the virtual host config.
              '';
              default = null;
              example = {
                root = "/var/root";
              };
            };
            dashboard.name = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                Application name.
              '';
              example = "App";
              default = null;
            };
            dashboard.category = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                App category tag.
              '';
              example = "app";
              default = null;
            };
            dashboard.icon = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                Font Awesome application icon.
              '';
              example = "rss";
              default = null;
            };
          };
        });
      description = ''
        Defines a web application.
      '';
      default = {};
    };
  };

  config = let
    cfg = config.webapps;
  in {
    security.acme = {
      acceptTerms = true;
      defaults.email = "pavel@borzenkov.net";
      certs."${cfg.domain}" = {
        extraDomainNames = ["*.${cfg.domain}"] ++ builtins.map (d: "*.${d}.${cfg.domain}") cfg.subDomains;
        dnsProvider = cfg.acmeDNSProvider;
        dnsResolver = "1.1.1.1:53";
        credentialsFile = cfg.acmeCredentialsFile;
        dnsPropagationCheck = true;
        group = config.users.users.nginx.group;
      };
    };
    systemd.services."acme-${cfg.domain}".after = ["network-online.target"];

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts =
        {
          "${cfg.domain}" = {
            default = true;
            locations."/".return = "404";
            forceSSL = true;
            useACMEHost = cfg.domain;
          };
        }
        // lib.mapAttrs'
        (
          vhostName: vhostConfig:
            lib.nameValuePair "${vhostConfig.subDomain}.${cfg.domain}" (
              let
                needAuth = lib.any (x: x) (lib.mapAttrsToList (locName: locConfig: locConfig.auth) vhostConfig.locations);
              in
                {
                  forceSSL = true;
                  useACMEHost = cfg.domain;
                  locations =
                    (lib.mapAttrs
                      (locName: locConfig: ({
                          proxyPass =
                            if vhostConfig.proxyTo != null
                            then "${vhostConfig.proxyTo}$request_uri"
                            else null;
                          extraConfig = lib.optionalString locConfig.auth ''
                            auth_request /auth;
                            error_page 401 = @error401;

                            auth_request_set $cookie $upstream_http_set_cookie;
                            add_header Set-Cookie $cookie;
                            auth_request_set $username $upstream_http_x_username;
                            proxy_set_header ${cfg.userIDHeader} $username;
                          '';
                        }
                        // lib.optionalAttrs (locConfig.custom != null) locConfig.custom))
                      vhostConfig.locations)
                    // lib.optionalAttrs needAuth {
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

                      "@error401" = lib.optionalAttrs needAuth {
                        return = "302 https://${cfg.ssoSubDomain}.${cfg.domain}/login?go=$scheme://$http_host$request_uri";
                      };
                    };
                }
                // lib.optionalAttrs (vhostConfig.custom != null) vhostConfig.custom
            )
        )
        cfg.apps;
    };

    lib.webapps.homerServices = let
      apps = builtins.filter (a: a.dashboard.name != null) (lib.attrValues cfg.apps);
    in
      lib.forEach cfg.dashboardCategories (
        cat: let
          catApps = lib.sort (a: b: a.dashboard.name < b.dashboard.name) (
            builtins.filter
            (a:
              a.dashboard.category
              != null
              && a.dashboard.category == cat.tag
              || a.dashboard.category == null && cat.tag == "misc")
            apps
          );
        in {
          name = cat.name;
          items = lib.forEach catApps (a: {
            name = a.dashboard.name;
            icon = lib.optionalString (a.dashboard.icon != null) "fas fa-${a.dashboard.icon}";
            url = "${
              if lib.attrByPath ["custom" "forceSSL"] true a
              then "https"
              else "http"
            }://${a.subDomain}.${cfg.domain}";
            target = "_blank";
          });
        }
      );
  };
}
