{
  config,
  lib,
  pborlib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.vpn;

  resolve-dns-wg = pkgs.writeShellApplication {
    name = "resolve-dns-wg";
    text = builtins.readFile ./scripts/resolve-dns-wg.sh;
    runtimeInputs = [
      pkgs.wireguard-tools
    ];
  };
  endpoint = "vpn.borzenkov.net:13231";
  pubkey = "/qcJiPDpknM7hvAwfrxUS5D8IGJ3RAiTVYlfdg8eZzk=";
in
{
  imports = pborlib.allDirs ./.;

  options = {
    pbor.vpn.enable = (lib.mkEnableOption "Enable VPN") // {
      default = false;
    };
    pbor.vpn.address = lib.mkOption {
      type = lib.types.str;
      description = "IP address.";
    };
    pbor.vpn.keyfile = lib.mkOption {
      type = lib.types.str;
      description = "Path to a private key file.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      network = {
        enable = true;
        netdevs = {
          "50-wg" = {
            netdevConfig = {
              Kind = "wireguard";
              MTUBytes = "1420";
              Name = "wg0";
            };
            wireguardConfig = {
              ListenPort = 13231;
              PrivateKeyFile = cfg.keyfile;
            };
            wireguardPeers = [
              {
                PublicKey = pubkey;
                AllowedIPs = [
                  "192.168.88.0/24"
                  "192.168.111.0/24"
                ];
                Endpoint = endpoint;
                PersistentKeepalive = 15;
              }
            ];
          };
        };
        networks = {
          "50-wg" = {
            name = "wg0";
            DHCP = "no";
            addresses = [
              {
                Address = "${cfg.address}/24";
              }
            ];
            routes = [
              {
                Destination = "192.168.88.0/24";
                Scope = "link";
              }
            ];
            dns = [ "192.168.111.1" ];
            domains = [ "lab.borzenkov.net" ];
          };
        };
      };
      services.resolve-dns-wg0 = {
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${resolve-dns-wg}/bin/resolve-dns-wg wg0 ${endpoint} '${pubkey}'";
        };
      };
      timers.resolve-dns-wg0 = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "minutely";
        };
      };
    };
  };
}
