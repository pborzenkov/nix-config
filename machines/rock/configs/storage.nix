{ pkgs, ... }:
{
  fileSystems = {
    "/storage" = {
      device = "storage";
      fsType = "zfs";
    };
    "/fast-storage" = {
      device = "fast-storage";
      fsType = "zfs";
    };
  };

  users.groups.storage = {
    gid = 1000;
    members = [
      "pbor"
      "nobody"
    ];
  };

  systemd = {
    services.collect-storcli-metrics = {
      serviceConfig =
        let
          collect-metrics = pkgs.writeShellScriptBin "collect-metrics" ''
            METRICS_FILE="/var/lib/prometheus-node-exporter/storcli.prom"
            TMP_FILE="$(mktemp ''${METRICS_FILE}.XXXXXXX)"

            ${pkgs.storcli-collector}/bin/storcli-collector --storcli_path ${pkgs.storcli}/bin/storcli >> "$TMP_FILE"
            mv "$TMP_FILE" "$METRICS_FILE"
            chmod a+r "$METRICS_FILE"
          '';

        in
        {
          Type = "oneshot";
          User = "root";
          ExecStart = "${collect-metrics}/bin/collect-metrics";
        };
    };
    timers.collect-storcli-metrics = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "minutely";
      };
    };
  };

  services.prometheus = {
    exporters.smartctl = {
      enable = true;
    };
    scrapeConfigs = [
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [
              "rock.lab.borzenkov.net:9633"
            ];
          }
        ];
      }
    ];
  };

  boot.zfs.package = pkgs.zfs_2_4;
  services = {
    nfs.server = {
      enable = true;
      exports = ''
        /storage *(rw,insecure,sync,no_subtree_check,all_squash,anonuid=65534,anongid=1000)
      '';
    };
    zfs = {
      autoScrub = {
        enable = true;
        pools = [
          "fast-storage"
          "storage"
        ];
      };
      trim.enable = true;
    };
  };
  networking = {
    hostId = "dcf46265";
    firewall.allowedTCPPorts = [ 2049 ];
  };

  pbor.webapps.apps.storage = {
    subDomain = "storage";
    locations = {
      "/" = {
        custom = {
          root = "/storage";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
  };
}
