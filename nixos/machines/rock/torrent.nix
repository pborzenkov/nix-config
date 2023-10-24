{
  config,
  pkgs,
  lib,
  ...
}: let
  vpn = "amsterdam";
  cfg = config.services.transmission;
in {
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    performanceNetParameters = true;
    settings = {
      download-dir = "/storage/torrents";
      incomplete-dir = "${cfg.home}/incomplete";
      incomlete-dir-enabled = true;

      rpc-bind-address = "unix:///run/transmission/rpc.sock";
      rpc-socket-mode = "0666";
      rpc-whitelist-enabled = false;

      speed-limit-down = 15360;
      speed-limit-down-enabled = true;
      speed-limit-up = 15360;
      speed-limit-up-enabled = true;

      ratio-limit = 5;
      # ratio-limit-enabled = true;

      peer-limit-global = 1024;
      peer-limit-per-torrent = 128;
      upload-slots-per-torrent = 128;

      cache-size-mb = 32;
      prefetch-enabled = true;

      utp-enabled = true;
      dht-enabled = true;
      pex-enabled = true;
      encryption = 1;
      port-forwarding-enabled = false;
    };
  };

  systemd = {
    services = {
      transmission = {
        after = ["netns-${vpn}.service"];
        bindsTo = ["netns-${vpn}.service"];
        unitConfig = {
          JoinsNamespaceOf = ["netns-${vpn}.service"];
          RequiresMountsFor = ["/storage"];
        };
        serviceConfig = {
          PrivateNetwork = true;
          BindReadOnlyPaths = ["/etc/netns/${vpn}/resolv.conf:/etc/resolv.conf"];
          LimitNOFILE = 10240;
          StateDirectory = lib.mkForce [
            "transmission"
            "transmission/.config/transmission-daemon"
            "transmission/incomplete"
          ];
        };
      };

      flood = {
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        description = "flood system service";
        path = [pkgs.mediainfo];
        unitConfig = {
          RequiresMountsFor = ["/storage"];
        };
        serviceConfig = {
          DynamicUser = true;
          ReadWritePaths = "/storage/torrents";
          Type = "simple";
          Restart = "on-failure";
          StateDirectory = "flood";
          ExecStart = ''
            ${pkgs.flood}/bin/flood \
              --auth none \
              --rundir /var/lib/flood \
              --host 127.0.0.1 \
              --port 29200 \
              --trurl https://torrents.lab.borzenkov.net/transmission/rpc \
              --truser "" \
              --trpass "" \
              --allowedpath ${cfg.settings.download-dir} --allowedpath /storage/torrents
          '';
        };
      };

      transmission-exporter = {
        description = "Prometheus exporter for Transmission";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          DynamicUser = true;
          ExecStart = ''
            ${pkgs.nur.repos.pborzenkov.transmission-exporter}/bin/transmission-exporter \
              --transmission.url=unix:///run/transmission/rpc.sock
          '';
          Restart = "always";
        };
      };

      transmission-set-port = {
        unitConfig = {
          JoinsNamespaceOf = ["netns-${vpn}.service"];
        };
        serviceConfig = {
          DynamicUser = true;
          PrivateNetwork = true;
          ExecStart = let
            get_vpn_port = pkgs.writeShellScript "get_vpn_port.sh" ''
              IP_ADDR=$(${pkgs.iproute2}/bin/ip -4 addr show ${vpn} | ${pkgs.gawk}/bin/awk '/inet/{ print ''$2 }' | cut -d/ -f1)
              if [ $? -ne 0 ]; then
                echo "No VPN interface"
                exit 0
              fi

              IFS='.' read -ra ADDR <<< "''$IP_ADDR"
              function d2b() {
                  printf "%08d" $(echo "obase=2;$1"|${pkgs.bc}/bin/bc)
              }
              port_bin="$(d2b ''${ADDR[2]})$(d2b ''${ADDR[3]})"
              echo $(printf "%04d" $(echo "ibase=2; ''${port_bin:4}" | ${pkgs.bc}/bin/bc))
            '';
          in
            pkgs.writeShellScript "transmission-set-port.sh" ''
              HAS_PORT=$(${pkgs.transmission_4}/bin/transmission-remote --unix-socket /run/transmission/rpc.sock --json -si | ${pkgs.jq}/bin/jq -r '.arguments."peer-port"')
              if [ -z "''${HAS_PORT}" ]; then
                echo "Transmission not running"
              fi

              WANT_PORT=1$(${get_vpn_port})
              if [ -z "''${WANT_PORT}" ]; then
                echo "Can't get desired port"
              fi

              if [ "''${HAS_PORT}" -ne "''${WANT_PORT}" ]; then
                echo "want: ''${WANT_PORT}, has: ''${HAS_PORT}, reconfiguring"
                ${pkgs.transmission_4}/bin/transmission-remote --unix-socket /run/transmission/rpc.sock -p ''${WANT_PORT}
              else
                echo "want: ''${WANT_PORT}, has: ''${HAS_PORT}"
              fi
            '';
        };
      };
    };

    timers.transmission-set-port = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "minutely";
      };
    };
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "transmission";
      static_configs = [
        {
          targets = [
            "rock.lab.borzenkov.net:29100"
          ];
        }
      ];
    }
  ];

  webapps.apps.torrents = {
    subDomain = "torrents";
    locations = {
      "/" = {
        custom = {
          tryFiles = "$uri /index.html";
          root = "${pkgs.flood}/lib/node_modules/flood/dist/assets";
        };
      };
      "/api" = {
        custom = {
          proxyPass = "http://127.0.0.1:29200";
        };
      };
      "/transmission/rpc" = {
        custom = {
          proxyPass = "http://unix:/run/transmission/rpc.sock";
        };
      };
    };
    dashboard = {
      name = "Torrents";
      category = "app";
      icon = "download";
    };
  };
}
