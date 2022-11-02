{ config, pkgs, lib, ... }:
let
  vpn = "amsterdam";
  cfg = config.services.rtorrent;
  get_vpn_port = pkgs.writeShellScript "get_vpn_port.sh" ''
    IP_ADDR=$(${pkgs.iproute2}/bin/ip -4 addr show ${vpn} | ${pkgs.gawk}/bin/awk '/inet/{ print ''$2 }' | cut -d/ -f1)
    if [ $? -ne 0 ]; then
      exit 1
    fi

    IFS='.' read -ra ADDR <<< "''$IP_ADDR"
    function d2b() {
        printf "%08d" $(echo "obase=2;$1"|${pkgs.bc}/bin/bc)
    }
    port_bin="$(d2b ''${ADDR[2]})$(d2b ''${ADDR[3]})"
    echo $(printf "%04d" $(echo "ibase=2; ''${port_bin:4}" | ${pkgs.bc}/bin/bc))
  '';
in
{
  services = {
    rtorrent = {
      enable = true;
      configText = lib.mkForce ''
        ##### Various basic configuration options
        # RPC socket location
        method.insert = cfg.rpcsock, private|const|string, (cat,"${cfg.rpcSocket}")

        # Runtime directory
        method.insert = cfg.basedir, private|const|string, (cat,"${cfg.dataDir}/")
        # Session directory
        method.insert = cfg.session,  private|const|string, (cat,(cfg.basedir),".session/")
        # Location of unfinished downloads
        method.insert = cfg.download, private|const|string, (cat,"${cfg.downloadDir}")

        # Logs
        method.insert = cfg.logs,     private|const|string, (cat,(cfg.basedir),"log/")
        method.insert = cfg.logfile,  private|const|string, (cat,(cfg.logs),"rtorrent-",(system.time),".log")

        # Create necessary directories
        execute.throw = sh, -c, (cat, "mkdir -p ", (cfg.download), " ", (cfg.logs), " ", (cfg.session))

        # Basic settings
        session.path.set = (cat, (cfg.session))
        directory.default.set = (cat, (cfg.download))
        log.execute = (cat, (cfg.logs), "execute.log")
        print = (cat, "Logging to ", (cfg.logfile))
        log.open_file = "log", (cfg.logfile)
        log.add_output = "warn", "log"
        encoding.add = utf8
        system.umask.set = 0027
        system.cwd.set = (directory.default)

        # Allow large RPC responses
        network.xmlrpc.size_limit.set = 8M

        # XML-RPC interface
        network.scgi.open_local = (cat,(cfg.rpcsock))
        schedule = scgi_group,0,0,"execute.nothrow=chown,\":rtorrent\",(cfg.rpcsock)"
        schedule = scgi_permission,0,0,"execute.nothrow=chmod,\"g+w,o+w\",(cfg.rpcsock)"

        # Configure DHT and PEX
        dht.mode.set = on
        protocol.pex.set = yes
        trackers.use_udp.set = yes
        network.port_random.set = no

        # Allow enryption
        protocol.encryption.set = allow_incoming,try_outgoing,enable_retry
        #####

        ##### Performance tuning
        # Max memory that can be occupied by data pieces
        pieces.memory.max.set = 8G

        # Max number of open HTTP connections
        network.http.max_open.set = 50

        # Max number of open files and sockets
        network.max_open_files.set = 2000;
        network.max_open_sockets.set = 5000; 

        # Maximum number of download and upload slots
        throttle.max_downloads.global.set = 1000
        throttle.max_uploads.global.set   = 1000

        # Ask tracker for 100 peers
        trackers.numwant.set = 100

        # Maximum number of download and upload slots per torrent
        throttle.max_downloads.set = 100
        throttle.max_uploads.set = 100

        # Maximum number of peers per torrent during downloading
        throttle.min_peers.normal.set = 99
        throttle.max_peers.normal.set = 100

        # Maximum number of peers per torrent during seeding
        throttle.min_peers.seed.set = -1
        throttle.max_peers.seed.set = -1

        # Default socket sizes
        network.receive_buffer.size.set =  4M
        network.send_buffer.size.set    = 12M
        #####

        # Move finished torrents to /storage/torrents
        method.insert = d.get_finished_dir, simple, "cat=/storage/torrents/,$d.custom1="
        method.insert = d.get_data_full_path, simple, "branch=((d.is_multi_file)),((cat,(d.directory))),((cat,(d.directory),/,(d.name)))"
        method.insert = d.move_to_complete, simple, "execute=mkdir,-p,$argument.1=; execute=cp,-rp,$argument.0=,$argument.1=; d.stop=; d.directory.set=$argument.1=; d.start=;d.save_full_session=; execute=rm, -r, $argument.0="
        method.set_key = event.download.finished,move_complete,"d.move_to_complete=$d.get_data_full_path=,$d.get_finished_dir="

        # Limit upload/download to 15M/s
        throttle.global_down.max_rate.set_kb = 15360
        throttle.global_up.max_rate.set_kb = 15360

        # Bootstrap DHT
        schedule2 = dht_node, 30, 0, "dht.add_node=router.utorrent.com:6881"
        schedule2 = dht_node, 30, 0, "dht.add_node=router.bittorrent.com:6881"
        schedule2 = dht_node, 30, 0, "dht.add_node=dht.transmissionbt.com:6881"
        schedule2 = dht_node, 30, 0, "dht.add_node=router.bitcomet.com:6881"
        schedule2 = dht_node, 30, 0, "dht.add_node=dht.aelitis.com:6881"
      '';
    };
  };

  systemd.services = {
    rtorrent =
      let
        configFile = pkgs.writeText "rtorrent.rc" cfg.configText;
      in
      {
        after = [ "netns-${vpn}.service" "openvpn-${vpn}.service" ];
        bindsTo = [ "netns-${vpn}.service" "openvpn-${vpn}.service" ];
        unitConfig = {
          JoinsNamespaceOf = [ "netns-${vpn}.service" ];
          RequiresMountsFor = [ "/storage" ];
        };
        serviceConfig = {
          PrivateNetwork = true;
          BindReadOnlyPaths = [ "/etc/netns/${vpn}/resolv.conf:/etc/resolv.conf" ];
          LimitNOFILE = 10240;

          EnvironmentFile = [ "-/var/run/rtorrent/dynamic.env" ];
          ExecStartPre = lib.mkForce
            (pkgs.writeShellScript "rtorrent-prestart.sh" ''
              ${pkgs.bash}/bin/bash -c "if test -e ${cfg.dataDir}/session/rtorrent.lock && test -z $(${pkgs.procps}/bin/pidof rtorrent); then rm -f ${cfg.dataDir}/session/rtorrent.lock; fi"
              echo "EXTERNAL_ADDRESS=$(${pkgs.curl}/bin/curl ifconfig.co)" > /var/run/rtorrent/dynamic.env
              echo "PEER_PORT=1$(${get_vpn_port})" >> /var/run/rtorrent/dynamic.env
              echo "DHT_PORT=2$(${get_vpn_port})" >> /var/run/rtorrent/dynamic.env
            ''
            );
          ExecStart = lib.mkForce ''
            ${cfg.package}/bin/rtorrent -n -o system.daemon.set=true \
              -o network.local_address.set=''${EXTERNAL_ADDRESS} \
              -o network.port_range.set=''${PEER_PORT}-''${PEER_PORT} \
              -o dht.port.set=''${DHT_PORT} \
              -o import=${configFile}
          '';
        };
      };

    flood = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "flood system service";
      path = [ pkgs.mediainfo ];
      serviceConfig = {
        User = "flood";
        Group = "rtorrent";
        DynamicUser = true;
        Type = "simple";
        Restart = "on-failure";
        StateDirectory = "flood";
        ExecStart = ''
          ${pkgs.flood}/lib/node_modules/flood/dist/index.js \
            --auth none \
            --rundir /var/lib/flood \
            --host 127.0.0.1 \
            --port 29200 \
            --rtsocket ${cfg.rpcSocket} \
            --allowedpath ${cfg.downloadDir} --allowedpath /storage/torrents
        '';
      };
    };

    rtorrent-exporter = {
      description = "Prometheus exporter for RTorrent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.rtorrent-exporter}/bin/rtorrent-exporter \
            -a 0.0.0.0:29201 \
            -r https://torrents.lab.borzenkov.net/RPC2
        '';
        Restart = "always";
        DynamicUser = true;
      };
    };

  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "rtorrent";
      static_configs = [
        {
          targets = [
            "rock.lab.borzenkov.net:29201"
          ];
        }
      ];
    }
  ];

  sops.secrets = {
    perfect-privacy-password = { };
    perfect-privacy-openvpn-key = { };
  };

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
      "/RPC2" = {
        custom = {
          extraConfig = ''
            scgi_pass  unix:/var/run/rtorrent/rpc.sock;
          '';
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
