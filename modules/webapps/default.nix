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
      cfg = config.backup;
    in
    { };
}
