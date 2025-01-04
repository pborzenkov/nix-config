{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.webapps;
in {
  options.pbor.webapps = {
    enable = lib.mkEnableOption "Enable webapps";

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
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          subDomain = lib.mkOption {
            type = lib.types.str;
            description = ''
              'Subdomain of the web application.
            '';
            example = "grafana";
          };
          auth = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                rbac = lib.mkOption {
                  type = lib.types.nullOr (
                    lib.types.listOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str))
                  );
                  description = ''
                    List of users/groups for proxy based auth
                  '';
                  example = ["groups:rss"];
                  default = null;
                };
              };
            });
            default = null;
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
                skip_auth = lib.mkOption {
                  type = lib.types.bool;
                  description = ''
                    Skip auth for this location.
                  '';
                  default = false;
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
          dashboard = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Application name.
                  '';
                  example = "App";
                };
                category = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    App category tag.
                  '';
                  example = "app";
                };
                icon = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Font Awesome application icon.
                  '';
                  example = "rss";
                };
              };
            });
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

  config = lib.mkIf cfg.enable {
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
                needsAuth =
                  vhostConfig.auth
                  != null
                  && vhostConfig.auth.rbac != null
                  && (lib.any (x: !x) (
                    lib.mapAttrsToList (_: locConfig: locConfig.skip_auth) vhostConfig.locations
                  ));
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
                          extraConfig = lib.optionalString (needsAuth && !locConfig.skip_auth) ''
                            auth_request /internal/authelia/auth;

                            auth_request_set $user $upstream_http_remote_user;
                            auth_request_set $groups $upstream_http_remote_groups;
                            auth_request_set $name $upstream_http_remote_name;
                            auth_request_set $email $upstream_http_remote_email;

                            proxy_set_header Remote-User $user;
                            proxy_set_header Remote-Groups $groups;
                            proxy_set_header Remote-Email $email;
                            proxy_set_header Remote-Name $name;

                            auth_request_set $redirection_url $upstream_http_location;

                            error_page 401 =302 $redirection_url;
                          '';
                        }
                        // lib.optionalAttrs (locConfig.custom != null) locConfig.custom))
                      vhostConfig.locations)
                    // lib.optionalAttrs needsAuth {
                      "/internal/authelia/auth" = {
                        proxyPass = "${cfg.ssoInternalAddress}/api/authz/auth-request";
                        extraConfig = ''
                          internal;

                          proxy_set_header X-Original-Method $request_method;
                          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                          proxy_set_header X-Forwarded-For $remote_addr;
                          proxy_set_header Content-Length "";
                          proxy_set_header Connection "";

                          proxy_pass_request_body off;
                          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
                          proxy_redirect http:// $scheme://;
                          proxy_http_version 1.1;
                          proxy_cache_bypass $cookie_session;
                          proxy_no_cache $cookie_session;
                          proxy_buffers 4 32k;
                          client_body_buffer_size 128k;
                        '';
                      };
                    };
                }
                // lib.optionalAttrs (vhostConfig.custom != null) vhostConfig.custom
            )
        )
        cfg.apps;
    };

    lib.pbor.webapps.homerServices = let
      apps = builtins.filter (a: a.dashboard != null) (lib.attrValues cfg.apps);
    in
      lib.forEach cfg.dashboardCategories (
        cat: let
          catApps = lib.sort (a: b: a.dashboard.name < b.dashboard.name) (
            builtins.filter
            (a: a.dashboard.category == cat.tag)
            apps
          );
        in {
          name = cat.name;
          items = lib.forEach catApps (a: {
            name = a.dashboard.name;
            icon = "fas fa-${a.dashboard.icon}";
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
