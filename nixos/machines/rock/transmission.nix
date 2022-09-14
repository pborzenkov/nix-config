{ config, lib, pkgs, ... }:

let
  transmissionIP = "192.168.88.200";
in
{
  containers.transmission = {
    autoStart = true;
    ephemeral = true;
    enableTun = true;
    macvlans = [ "enp2s0" ];

    bindMounts = {
      "/run/secrets/perfect-privacy-password" = {
        hostPath = config.sops.secrets.perfect-privacy-password.path;
        isReadOnly = true;
      };
      "/run/secrets/perfect-privacy-openvpn-key" = {
        hostPath = config.sops.secrets.perfect-privacy-openvpn-key.path;
        isReadOnly = true;
      };
      "/var/lib/transmission" = {
        hostPath = "/var/lib/transmission";
        isReadOnly = false;
      };
    };

    config = {
      networking = {
        firewall.enable = false;
        useDHCP = false;
        dhcpcd.enable = false;
        useNetworkd = true;
        useHostResolvConf = false;
      };

      systemd.network = {
        enable = true;
        networks."40-macvlan" = {
          name = "mv-enp2s0";
          address = [ "${transmissionIP}/24" ];
          dns = [ "192.168.88.1" ];
          gateway = [ "192.168.88.1" ];
        };
      };

      fileSystems."/storage" = {
        device = "helios64.lab.borzenkov.net:/storage";
        fsType = "nfs";
      };

      services = {
        resolved.enable = true;

        openvpn.servers =
          let
            calcport = ''
              IFS='.' read -ra ADDR <<< "$ifconfig_local"
              function d2b() {
                  printf "%08d" $(echo "obase=2;$1" | ${pkgs.bc}/bin/bc)
              }
              port_bin="$(d2b ''${ADDR[2]})$(d2b ''${ADDR[3]})"
              port=1$(printf "%04d" $(echo "ibase=2; ''${port_bin:4}"| ${pkgs.bc}/bin/bc))
            '';
            route-up = pkgs.writeShellScript "openvpn-pp-route-up" ''
              ${pkgs.iproute2}/bin/ip route add $trusted_ip/32 via $route_net_gateway
              ${pkgs.iproute2}/bin/ip route del default
              ${pkgs.iproute2}/bin/ip route add default via $route_vpn_gateway

              ${calcport}
              ${pkgs.coreutils}/bin/echo -e "VPN_IP=$ifconfig_local\nVPN_PORT=$port" > /run/pp.env

              ${pkgs.systemd}/bin/systemctl start transmission
            '';
            route-pre-down = pkgs.writeShellScript "openvpn-pp-route-pre-down" ''
              ${pkgs.systemd}/bin/systemctl --force --force halt
            '';
          in
          {
            perfect-privacy = {
              updateResolvConf = true;
              config = ''
                auth-user-pass /run/secrets/perfect-privacy-password
                client
                dev pp0
                dev-type tun
                hand-window 120
                inactive 604800
                mute-replay-warnings
                nobind
                persist-key
                persist-remote-ip
                persist-tun
                ping 5
                ping-restart 120
                remote-random
                reneg-sec 3600
                resolv-retry 60
                route-delay 2
                route-noexec
                route-up ${route-up}
                route-pre-down ${route-pre-down}
                script-security 2
                tls-cipher TLS_CHACHA20_POLY1305_SHA256:TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS_AES_256_GCM_SHA384:TLS-RSA-WITH-AES-256-CBC-SHA
                tls-timeout 5
                verb 4

                tun-mtu  1500
                tun-mtu-extra  32
                mssfix 1450

                proto udp

                remote 31.204.150.106 44
                remote 31.204.150.106 443
                remote 31.204.150.106 4433
                remote 31.204.150.138 44
                remote 31.204.150.138 443
                remote 31.204.150.138 4433
                remote 31.204.152.102 44
                remote 31.204.152.102 443
                remote 31.204.152.102 4433
                remote 31.204.152.189 44
                remote 31.204.152.189 443
                remote 31.204.152.189 4433
                remote 31.204.153.106 44
                remote 31.204.153.106 443
                remote 31.204.153.106 4433

                cipher AES-256-GCM
                auth SHA512

                remote-cert-tls server

                <ca>
                -----BEGIN CERTIFICATE-----
                MIIGgzCCBGugAwIBAgIJAPoRtcSqaa9pMA0GCSqGSIb3DQEBDQUAMIGHMQswCQYD
                VQQGEwJDSDEMMAoGA1UECBMDWnVnMQwwCgYDVQQHEwNadWcxGDAWBgNVBAoTD1Bl
                cmZlY3QgUHJpdmFjeTEYMBYGA1UEAxMPUGVyZmVjdCBQcml2YWN5MSgwJgYJKoZI
                hvcNAQkBFhlhZG1pbkBwZXJmZWN0LXByaXZhY3kuY29tMB4XDTE2MDEyNzIxNTIz
                N1oXDTI2MDEyNDIxNTIzN1owgYcxCzAJBgNVBAYTAkNIMQwwCgYDVQQIEwNadWcx
                DDAKBgNVBAcTA1p1ZzEYMBYGA1UEChMPUGVyZmVjdCBQcml2YWN5MRgwFgYDVQQD
                Ew9QZXJmZWN0IFByaXZhY3kxKDAmBgkqhkiG9w0BCQEWGWFkbWluQHBlcmZlY3Qt
                cHJpdmFjeS5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQClq5za
                5kZf3qUTqbFeLUDTGBd2SUOVeTG3hFegFR958X9FOCINJtTveSyJ6cgW7PO3si1X
                SyTjr8TaUULG5HXH3DpmzYoMltQ0fHJYfGy9gxJMfQJ9EwqqNnslAIokMEoWAnMz
                /TAyGbr/J2Yx/ys7ehaIOnCIhNESZkxj9muUVWLi0LvyBz7QKFafZH7QEulmKoGn
                OeorIFclrr964oxe2dE32CoN8lYTkpmwnAgXwkeSrgAVE9gjVnKc58xRdnk1JBam
                HKh6mvr4AYzU1TyB4g57tJlvjmVswy8+zY7l/1h0QDMTYK+ob9FVvKWVe7IWQLb7
                CG5i8QhHYUOPv20IS93KH7qrb7/EeL0tnidlXyDxpGF3RebgWiPS7cHOj5FTOaCI
                oZ1o+YfzpUqiENgfal2BBcG+MHTu+yt2t35tooL378D733HM8DYsxG2krhOpIuah
                kCgq7sRpbbTn+fwxu6+TR6dqXPT7hYIcqoDzrUNrtan+InTziClOWYTeDKi4cndN
                9KefN4WUMYapg1K9lcKH2Y0ARY5gOy9r8Dbw7QXTZOfVRJqSFbh8t3EZVHXcsF1p
                PJXRzJAzOIoFVc/waSk2ASYS95sk50ae+0befGzOX1epGZCZh4HRraiNrttfU+mk
                duGresJdp8wIZpd7o14iEF8f2YBtGQjlWsQoqQIDAQABo4HvMIHsMB0GA1UdDgQW
                BBSGT7htGCobPI8nNCnwgZ+6bmEO4TCBvAYDVR0jBIG0MIGxgBSGT7htGCobPI8n
                NCnwgZ+6bmEO4aGBjaSBijCBhzELMAkGA1UEBhMCQ0gxDDAKBgNVBAgTA1p1ZzEM
                MAoGA1UEBxMDWnVnMRgwFgYDVQQKEw9QZXJmZWN0IFByaXZhY3kxGDAWBgNVBAMT
                D1BlcmZlY3QgUHJpdmFjeTEoMCYGCSqGSIb3DQEJARYZYWRtaW5AcGVyZmVjdC1w
                cml2YWN5LmNvbYIJAPoRtcSqaa9pMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEN
                BQADggIBAEI4PSBXw1jzsDGDI/wKtar1N1NhfJJNWWFTQSXgPZXHYIys7dsXTHCa
                ZgiIuOP7L8DmgwfqmvtcO5wVyacmXAHAliKYFOEkM/s56jrhdUM02KHd12lv9KVw
                E5jT4OZJYvHd651UKtHuh1nMuIlo4SQZ9R9WitTKumi7Nfr5XjdxGWqgz2c868aT
                q5CgCT2fpWfbN72n7hWNNO04TAwoXt69qv6ws/ymUGbHSshyBO4HtBMFTUzalZZ/
                YlJJIggsYP+LrmKPLDrjQVWcTYZKp0eIq3bfDHE/MlgVd6bd27JaPDOvcFQmFpMH
                crSL4tu1o070NsQmrT52rvcnpEvbsMtFK4vW7LxY677fUIZcwA/fWfLSKhQbxr0r
                anxKqztrY3Ey2bWEXOtmquxje44VFZrcSbfM8K+xBc0SUTTLoVzey/7SfzvIJsHH
                /UBkJZZYiAA/gAOqoF5bYFVFU9eoN1owOBednkGOn17yp0ssSDHWpCKBma29V7DR
                b4Huz0n270M25zuQn5YbNYRiMRm7wN8Y+9nqsqxryOc48Rv7FPonDzbskFFjKp7K
                PRcKXEPxzswHChAWeRG8nU4hRLVvuLdwN08AIV3T1P+ycTOIM8+RFJgiouyCNuw8
                UpIngQ4XIBteVNISnQHvuqACJWXJat3CnMekksqTIcCgAtk5F8rw
                -----END CERTIFICATE-----
                </ca>

                <cert>
                -----BEGIN CERTIFICATE-----
                MIIG1DCCBLygAwIBAgIISJBF94RzzgcwDQYJKoZIhvcNAQENBQAwgYcxCzAJBgNV
                BAYTAkNIMQwwCgYDVQQIEwNadWcxDDAKBgNVBAcTA1p1ZzEYMBYGA1UEChMPUGVy
                ZmVjdCBQcml2YWN5MRgwFgYDVQQDEw9QZXJmZWN0IFByaXZhY3kxKDAmBgkqhkiG
                9w0BCQEWGWFkbWluQHBlcmZlY3QtcHJpdmFjeS5jb20wHhcNMjIwNzIwMDAwMDAw
                WhcNMjQwMzE2MDAwMDAwWjCBgDELMAkGA1UEBhMCQ0gxDDAKBgNVBAgTA1p1ZzEY
                MBYGA1UEChMPUGVyZmVjdCBQcml2YWN5MR8wHQYDVQQDExZQZXJmZWN0IFByaXZh
                Y3kgQ2xpZW50MSgwJgYJKoZIhvcNAQkBFhlhZG1pbkBwZXJmZWN0LXByaXZhY3ku
                Y29tMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAyZpB4UJ9l8OV6Ox6
                ipe4haIHz6TQxeEya5PbVptVhT8Ly1CdPseYnzAL49OmBP4jFo/w6P7ybivoqcSa
                6+v21M0lisrHj6yBXEPVDMDcP68dXZWmDd+k3YMZMSW7icTMFVNImdkdsiQ1AXho
                2KP82Tgm8RaASzhV1hbSHLjuEEyO2lY/E5jBX/I4DR+s6mBUUXRm1xOl8j2xju3A
                kCa2fJpt23ycgQEQ6GE3kpfWflGTYjIW8ejTu/mtS3+eh/Xtwv9s3elsn0Vt8MX0
                9rt/9AWjAe7o6208zf2crj0n4NtP1pSEX8kV1cJ0O6BRBTlIj5oiuv3afaoQkhQF
                PohDcB77JcfdjAiwUlu5vu3nJi2pWEh2JiLxd+5Nvoa46BjtOqSY2X1t9ScGcI4p
                kVTQJvawrGnQhB9fgCBOV275Rjev1F2Cr1ZuZxbUPVRyBNFJBDGTyed1f4UWtfBm
                Vcn4+oWcuNEIZ8eP474yx+2VnMoJOBmdeYZUfEjgUM4KSRDGLybT9M9Rxwj8TXCt
                eudMr6qJ7HAszEpw8h7hO0SSBMTqTJAFYEa74V1izQG1xh3WOg2PF2aDlxsfxSta
                h4XEv6UTzxtwbNCgbUreTThVhBZMb132PQwg1y0tvP4FxOiRP2uw6n9Rv+MAOCja
                6Ue+wdoaJquACzRAFHavcsJNq3UCAwEAAaOCAUcwggFDMAkGA1UdEwQCMAAwIwYJ
                YIZIAYb4QgENBBYWFFZQTiBVc2VyIENlcnRpZmljYXRlMBEGCWCGSAGG+EIBAQQE
                AwIHgDALBgNVHQ8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwIwHQYDVR0OBBYE
                FOO2rq/+RHtawlvMwiN8hKTqrk99MIG8BgNVHSMEgbQwgbGAFIZPuG0YKhs8jyc0
                KfCBn7puYQ7hoYGNpIGKMIGHMQswCQYDVQQGEwJDSDEMMAoGA1UECBMDWnVnMQww
                CgYDVQQHEwNadWcxGDAWBgNVBAoTD1BlcmZlY3QgUHJpdmFjeTEYMBYGA1UEAxMP
                UGVyZmVjdCBQcml2YWN5MSgwJgYJKoZIhvcNAQkBFhlhZG1pbkBwZXJmZWN0LXBy
                aXZhY3kuY29tggkA+hG1xKppr2kwDQYJKoZIhvcNAQENBQADggIBAHJ6synAHIKr
                j3rZq3bGyvlJ1uoFbz+YrflrObWIKG0AEEbRlF5KyZEonObpAmlSA22M1ed01kni
                WvAJpT3rsVF0zOMucsSSqamEmTdATHhud46salqVfl42r+H4BujOAjxf29tPc4Yo
                owoNRPuRUK0aol3H7jrk35PN5BlSXdHt5MlbR0YLdioUXwRpvtNjUJd1Y9DG3vkz
                WvF4ftyyROG0u43Q3iaotgPsHsq4NHhf3UcP2VMSsiyHBENSlMUZO9g3JuIyncyg
                3BpcPXbhZBscBsSrjtJOhQWIXgme3ENhdPeNzCMe6Uz+770243cHWBg6QfR5E6WT
                2YxN2tQH/xFqZtMk7k2eqcnxbWZQHMZC/UEXxjPY/ubwsdPFdfIDAkfFcVrXuTyd
                X9fjCckBBTYjbnoSRgKqrG2vmxtpUgI5wyqI/sjNsKvEUTO4pHCnoCSuKKzql6og
                6rwHhqu4tEH+euGNWWTVhqKsQ1b4Q0ElwOmC8inaM3nhFQjRuzE9bwv4X29N/4Cy
                3XpLSZYuef/O07MxltAOY289k7Io8rBU6/poz0YhTyaTqNmPoZRdEFtyO+2n/P6W
                bUVhK3sJvd9A1UwpaI0akOBk663O2Kx3nun/p5tQaYGp5U7VKf+faq5HH7hsQRwd
                Xhf9G/ruaU3ojvr/CCTPcR5PSJCxY1vU
                -----END CERTIFICATE-----
                </cert>

                key /run/secrets/perfect-privacy-openvpn-key

                <tls-crypt>
                -----BEGIN OpenVPN Static key V1-----
                d10a8e2641f5834f6c5e04a6ee9a7985
                53d338fa2836ef2a91057c1f6174a3a1
                2b36f16d1110b20e42ae94d3bd579213
                e9c3770be6c74804348dddba876945a5
                a3ab7660f9436f85f331641f6efc8131
                5f0d12b2766a9f15c10a53cf9ba32dc8
                0f03b5f15a6cc6987bda795dbe83443e
                c81f3d5e161cd47fab6b1f125b3adeee
                1eae33370d018594e0ff6b25b815228d
                27371b32c82a95f4929d3abb5fa36e57
                bf1f42353542568fbb8233f4645f0582
                0275f79570cb8bbcf8010fc5d20f07d0
                31a8227d45daf7349e34158c91a3d4e5
                add19cfa02f683f87609f6525fa05940
                16d11abf2de649f83ad54edd3e74e032
                e34b1bca685b8499916826d9aee11c13
                -----END OpenVPN Static key V1-----
                </tls-crypt>
              '';
            };
          };

        transmission = {
          enable = true;
          settings = {
            peer-port-random-on-start = false;
            port-forwarding-enabled = false;

            download-dir = "/storage/torrents";
            incomplete-dir-enabled = true;

            speed-limit-up = 12288;
            speed-limit-up-enabled = true;
            speed-limit-down = 12288;
            speed-limit-down-enabled = true;

            peer-limit-global = 1000;

            rpc-authentication-required = false;
            rpc-bind-address = "0.0.0.0";
            rpc-port = 9091;
            rpc-whitelist-enabled = true;
            rpc-whitelist = "192.168.88.*";
            rpc-host-whitelist-enabled = true;
            rpc-host-whitelist = "*";
          };
        };
      };

      systemd.services.transmission =
        let
          cfg = config.containers.transmission.config.services.transmission;
          baseConfig = pkgs.writeText "settings.json" (
            builtins.toJSON cfg.settings
          );
          configDir = "${cfg.home}/.config/transmission-daemon";

          transmission = pkgs.transmission.override { openssl = pkgs.openssl_1_1; };
        in
        {
          wantedBy = lib.mkForce [ ];
          serviceConfig = {
            ExecStartPre = lib.mkForce (
              "+" + pkgs.writeShellScript "transmission-prestart" ''
                install -D -m 600 -o '${cfg.user}' -g '${cfg.group}' ${baseConfig} ${configDir}/settings.json
              ''
            );
            EnvironmentFile = [
              "/run/pp.env"
            ];
            ExecStart = lib.mkForce (
              pkgs.writeShellScript "transmission-start" ''
                ${transmission}/bin/transmission-daemon \
                    --bind-address-ipv4 "$VPN_IP" \
                    --peerport "$VPN_PORT" \
                    --config-dir "${configDir}" \
                    --foreground
              ''
            );
          };
          unitConfig.RequiresMountsFor = [ "/storage" ];
        };

      system.stateVersion = "20.09";
    };
  };

  systemd.services."container@transmission".serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = "10m";
  };

  webapps.apps.transmission = {
    subDomain = "transmission-ui";
    proxyTo = "http://${transmissionIP}:9091";
    locations."/" = { auth = true; };
    dashboard = {
      name = "Transmission";
      category = "app";
      icon = "download";
    };
  };

  sops.secrets = {
    perfect-privacy-password = { };
    perfect-privacy-openvpn-key = { };
  };

  systemd.services.tg-bot-transmission = {
    description = "Telegram bot for Transmission";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
            ${pkgs.nur.repos.pborzenkov.tg-bot-transmission}/bin/bot \
        -telegram.allow-user=pborzenkov \
        -telegram.allow-user=mashahooyasha \
        -transmission.url="http://transmission.lab.borzenkov.net:9091"
      '';
      EnvironmentFile = [
        config.sops.secrets.tg-bot-transmission-environment.path
      ];
      Restart = "always";
      DynamicUser = true;
    };
  };

  systemd.services.transmission-exporter = {
    description = "Prometheus exporter for Transmission torrent client";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.nur.repos.pborzenkov.transmission-exporter}/bin/transmission-exporter \
        --transmission.url="http://transmission.lab.borzenkov.net:9091"
      '';
      Restart = "always";
      DynamicUser = true;
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

  sops.secrets.tg-bot-transmission-environment = { };
}
