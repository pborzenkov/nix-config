{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.transmission;
in
{
  services = {
    transmission = {
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

        speed-limit-down = 30720;
        speed-limit-down-enabled = true;
        speed-limit-up = 30720;
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

    flood = {
      enable = true;
      host = "127.0.0.1";
      port = 29200;
      extraArgs = [
        "--auth"
        "none"
        "--trurl"
        "https://torrents.lab.borzenkov.net/transmission/rpc"
        "--truser"
        ""
        "--trpass"
        ""
        "--allowedpath"
        "${cfg.settings.download-dir}"
        "--allowedpath"
        "/storage/torrents"
      ];
    };
  };

  systemd = {
    services = {
      transmission = {
        after = [ "wireguard-amsterdam.service" ];
        bindsTo = [ "wireguard-amsterdam.service" ];
        unitConfig = {
          JoinsNamespaceOf = [ "netns@amsterdam.service" ];
          RequiresMountsFor = [ "/storage" ];
        };
        serviceConfig = {
          PrivateNetwork = true;
          BindReadOnlyPaths = [ "/etc/netns/amsterdam/resolv.conf:/etc/resolv.conf" ];
          LimitNOFILE = 10240;
          StateDirectory = lib.mkForce [
            "transmission"
            "transmission/.config/transmission-daemon"
            "transmission/incomplete"
          ];
        };
      };

      transmission-exporter = {
        description = "Prometheus exporter for Transmission";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          DynamicUser = true;
          ExecStart = ''
            ${pkgs.nur.repos.pborzenkov.transmission-exporter}/bin/transmission-exporter \
              --transmission.url=unix:///run/transmission/rpc.sock
          '';
          Restart = "always";
        };
      };

      transmission-protonvpn-nat-pmp = {
        after = [ "wireguard-amsterdam.service" ];
        bindsTo = [ "wireguard-amsterdam.service" ];
        wantedBy = [ "multi-user.target" ];
        unitConfig = {
          JoinsNamespaceOf = [ "netns@amsterdam.service" ];
        };
        serviceConfig = {
          DynamicUser = true;
          PrivateNetwork = true;
          ExecStart = ''
            ${pkgs.transmission-protonvpn-nat-pmp}/bin/transmission-protonvpn-nat-pmp \
              -transmission.url unix:///run/transmission/rpc.sock \
              -gateway.ip 10.2.0.1
          '';
        };
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

  pbor.webapps.apps.torrents = {
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
          proxyPass = "http://unix:/run/transmission/rpc.sock:/transmission/rpc";
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
