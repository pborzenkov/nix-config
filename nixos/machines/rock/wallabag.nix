{ config, lib, pkgs, ... }:

let
  dataDir = "/var/lib/wallabag";

  phpPackage = pkgs.php74.withExtensions ({ all, ... }: with all;
    [
      session
      ctype
      dom
      simplexml
      gd
      mbstring
      tidy
      iconv
      curl
      gettext
      tokenizer
      bcmath
      intl
      filter
      pdo_pgsql
      json
    ]);
  configFile = pkgs.writeText "parameters.yml" (builtins.toJSON {
    parameters = {
      database_driver = "pdo_pgsql";
      database_socket = "/run/postgresql/.s.PGSQL.5432";
      database_name = "wallabag";
      database_user = "wallabag";
      database_table_prefix = "wallabag_";
      database_charset = "utf8";
      database_path = null;
      database_host = null;
      database_port = null;
      database_password = null;

      domain_name = "https://${config.webapps.apps.wallabag.subDomain}.${config.webapps.domain}";
      server_name = "Wallabag";

      mailer_transport = null;
      mailer_user = null;
      mailer_password = null;
      mailer_host = null;
      mailer_port = null;
      mailer_encryption = null;
      mailer_auth_mode = null;

      locale = "en";

      secret = "\${WALLABAG_SECRET}";

      twofactor_auth = false;
      twofactor_sender = null;
      fosuser_registration = false;
      fosuser_confirmation = false;
      from_email = "wallabag@borzenkov.net";

      fos_oauth_server_access_token_lifetime = 3600;
      fos_oauth_server_refresh_token_lifetime = 1209600;

      rss_limit = 50;

      rabbitmq_host = null;
      rabbitmq_port = null;
      rabbitmq_user = null;
      rabbitmq_password = null;
      rabbitmq_prefetch_count = 0;

      redis_scheme = "tcp";
      redis_host = "localhost";
      redis_port = 6379;
      redis_path = null;
      redis_password = null;

      sentry_dsn = null;
    };
  });

  setupConfig = pkgs.writeShellScriptBin "setup_config.sh" ''
    #!${pkgs.runtimeShell}
    export PATH="$PATH:${lib.makeBinPath [ pkgs.coreutils ]}";
    mkdir -p ${dataDir}/app
    chmod -R u+w ${dataDir}/app
    cp -R ${pkgs.wallabag}/app/* ${dataDir}/app
    [ -f ${dataDir}/app/config/parameters.yml ] && rm ${dataDir}/app/config/parameters.yml
    ${pkgs.envsubst}/bin/envsubst \
      -i ${configFile} \
      -o ${dataDir}/app/config/parameters.yml
    chown -R wallabag:wallabag ${dataDir}/app
  '';
  console = pkgs.writeShellScriptBin "wallabag-console" ''
    #! ${pkgs.runtimeShell}
    export PATH="$PATH:${lib.makeBinPath [ phpPackage pkgs.sudo ]}";
    cd ${pkgs.wallabag}
    export WALLABAG_DATA="${dataDir}"
    # export secrets
    export $(sudo grep -v '^#' ${config.sops.secrets.wallabag.path} | xargs -0)
    sudo=exec
    if [[ "$USER" != wallabag ]]; then
      sudo='exec sudo -u wallabag --preserve-env=WALLABAG_DATA --preserve-env=WALLABAG_SECRET'
    fi
    $sudo ${phpPackage}/bin/php ${pkgs.wallabag}/bin/console --env=prod "$@"
  '';
in
{
  users.users.wallabag = {
    home = dataDir;
    group = "wallabag";
    createHome = true;
    isSystemUser = true;
  };
  users.groups.wallabag.members = [ "wallabag" ];

  environment.systemPackages = [ console ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "wallabag" ];
    ensureUsers = [{
      name = "wallabag";
      ensurePermissions."DATABASE wallabag" = "ALL PRIVILEGES";
    }];
  };

  services.phpfpm.pools.wallabag = {
    user = "wallabag";
    group = "wallabag";
    settings = {
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 4;
      "pm.max_requests" = 500;
      "listen.owner" = config.services.nginx.user;
      "listen.group" = config.services.nginx.group;
      "listen.mode" = "0666";
    };
    phpPackage = phpPackage;
    phpEnv = {
      WALLABAG_DATA = "${dataDir}";
      "PATH" = lib.makeBinPath [ phpPackage ];
    };
    phpOptions = ''
      date.timezone = ${config.time.timeZone}
      memory_limit = 256M
      upload_max_filesize = 50M
      post_max_filesize = 50M
    '';
  };
  systemd.services."phpfpm-wallabag" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    serviceConfig = {
      EnvironmentFile = [
        config.sops.secrets.wallabag.path
      ];
      ExecStartPre = "${setupConfig}/bin/setup_config.sh";
    };
  };

  sops.secrets.wallabag = {
    owner = "pbor";
  };

  webapps.apps.wallabag = {
    subDomain = "wallabag";
    custom.root = "${pkgs.wallabag}/web";
    locations = {
      "/" = {
        custom = {
          priority = 900;
          tryFiles = "$uri /app.php$is_args$args";
        };
      };
      "~ ^/app\\.php(/|$)" = {
        custom = {
          priority = 200;
          extraConfig = ''
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            fastcgi_pass unix:${config.services.phpfpm.pools.wallabag.socket};
            fastcgi_split_path_info ^(.+\.php)(/.*)$;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param DOCUMENT_ROOT $realpath_root;
            fastcgi_param WALLABAG_DATA ${dataDir};
            internal;
          '';
        };
      };
      "~ \\.php$" = {
        custom = {
          priority = 1000;
          extraConfig = ''
            return 404;
          '';
        };
      };
    };
    dashboard = {
      name = "Wallabag";
      category = "app";
      icon = "shopping-bag";
    };
  };

  backup = {
    dbBackups.wallabag = {
      database = "wallabag";
    };
    fsBackups.wallabag = {
      paths = [
        "${dataDir}"
      ];
      excludes = [
        "${dataDir}/.snapshots"
      ];
    };
  };
} 
