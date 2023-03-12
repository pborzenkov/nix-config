{
  config,
  pkgs,
  ...
}: {
  services.netns.namespaces = {
    amsterdam = {
      sysctl = {
        "net.core.rmem_max" = 4194304;
        "net.core.wmem_max" = 12582912;
      };
    };
  };

  services.openvpn.servers.amsterdam = let
    ca = pkgs.writeText "ca.crt" ''
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
    '';
    cert = pkgs.writeText "client.crt" ''
      -----BEGIN CERTIFICATE-----
      MIIG1TCCBL2gAwIBAgIJAN7AZOxGAHXjMA0GCSqGSIb3DQEBDQUAMIGHMQswCQYD
      VQQGEwJDSDEMMAoGA1UECBMDWnVnMQwwCgYDVQQHEwNadWcxGDAWBgNVBAoTD1Bl
      cmZlY3QgUHJpdmFjeTEYMBYGA1UEAxMPUGVyZmVjdCBQcml2YWN5MSgwJgYJKoZI
      hvcNAQkBFhlhZG1pbkBwZXJmZWN0LXByaXZhY3kuY29tMB4XDTIyMDkxNDAwMDAw
      MFoXDTI0MDUxMTAwMDAwMFowgYAxCzAJBgNVBAYTAkNIMQwwCgYDVQQIEwNadWcx
      GDAWBgNVBAoTD1BlcmZlY3QgUHJpdmFjeTEfMB0GA1UEAxMWUGVyZmVjdCBQcml2
      YWN5IENsaWVudDEoMCYGCSqGSIb3DQEJARYZYWRtaW5AcGVyZmVjdC1wcml2YWN5
      LmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMOHy5tD56cRiQPL
      Go4g6Krqh4aP0XjBfWbD3T7epO0h21x0H0W6vD+fw7ymxXcWUc6V6HfI9fdcaqME
      y8HkCgfa4tBczePdh+KCa7quVMjdcifwraVuSewOKVJAC0JXDrNvp47AL6MUtJfT
      o4GR1Mxfe04YcnMaQt96z8pBzjS/xor+iNulWRtJPtglohUKeR2t5/7/riKrJu43
      11Dc1gEMwEiMQBNuOgAcO7Bg7rjJMt3jlG50G/TAwpVuZY4MqAsXMFY1db6SMbDM
      z3lcgZquG9YJ0D4lyOzF442k27vva+o1GfhkmYFQyLlcsJ7HwoGutlzComxOuxJi
      fE9olpt2HU95f8/q72kb3sy7vf3/v93xbsvb15Y116uhtM/YsPYhuWftGH93X4WG
      Mc577ZqvUUOXQ49m4sS+hGDA5eI3fIV7CceN4++dYyhXYvVKAeMJuJS1pkPhMRI2
      BQT2bTaeUiUSGtJeZB15BghAtewIDpf4QQUTHWgbwaa+0psBLsUTyukZ4d1JFWp8
      7YNLr7rWg0QswJB0/7C6GjM+eLT92sF067lP8PiKJdVWaVy7Z0+UPO0rTnxkqqFv
      nOoXEQByamTbTbETV85IAncbov61+0HdMDGlPUPX8DOLJj7zWhaFduc/N1DIrTN3
      mdzVopcLsJHfmLgEZBa04EUmt/9tAgMBAAGjggFHMIIBQzAJBgNVHRMEAjAAMCMG
      CWCGSAGG+EIBDQQWFhRWUE4gVXNlciBDZXJ0aWZpY2F0ZTARBglghkgBhvhCAQEE
      BAMCB4AwCwYDVR0PBAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMCMB0GA1UdDgQW
      BBT049oGhlLRe77HBFAXFVmAEDLnfTCBvAYDVR0jBIG0MIGxgBSGT7htGCobPI8n
      NCnwgZ+6bmEO4aGBjaSBijCBhzELMAkGA1UEBhMCQ0gxDDAKBgNVBAgTA1p1ZzEM
      MAoGA1UEBxMDWnVnMRgwFgYDVQQKEw9QZXJmZWN0IFByaXZhY3kxGDAWBgNVBAMT
      D1BlcmZlY3QgUHJpdmFjeTEoMCYGCSqGSIb3DQEJARYZYWRtaW5AcGVyZmVjdC1w
      cml2YWN5LmNvbYIJAPoRtcSqaa9pMA0GCSqGSIb3DQEBDQUAA4ICAQAOoPm1bdDZ
      vEfSsENDZHezgZuQpJ3pxpsSAuFVh3Qq7dQksFTgBKg65hzexk9Dfj6g/rsgKV9p
      IY014c9GJhTcj4vUWRwG22s+dR9gktPxLQD/tGsh84Bvi1jKEN25pKdZqfjEdyx9
      hZDTTnvs8W80guaBmpSd9fRUtvPtXUoVrR2Jejys9BW3eIYhfuC+D7tdjjgJMKcw
      Ng9RXZYwGZxAFRYkt376qzP1ZJjjefpUcSxIn+rGfXwYRYwI8EVRaHYsSRB3e00R
      0SMEIrXTIe4noV1ZkPNJ16NJ52qYi4a+hwkTykLNmcuPyIqmjypfGNCUVZdQJo/G
      oVrbAnt4L+CfBBFfx/dw8+bp9+02ExCgXgPrZczX2UtRhEO7zha4aBO3GslfNtrp
      l27K5btVCed9RKQI1JbCDv+9dmlHyv89qqrw85zetgPuaFCHtisty+UIFJYAALGR
      1qOGExMKKsyhG0sS/WQUdcqatLlqcrCgir0kwNinBKIyVdq/PFg7JTiQp/6nIoLp
      vr78gmlEl/OLB+J4DO71M1LPWO+GjDXTFhF/yV6SrFzhNpgGDOWJjD/VbR5c+o5F
      Iq48oqsxJENDM72g8t1r/hzBdLO5XuEAlHMtL7e53mrkBCJQiB55NQ7SSOI7JT5g
      C0ajrbTg5/hPs718BiAW1wHkGqo6D1cIAA==
      -----END CERTIFICATE-----
    '';
    tls-crypt = pkgs.writeText "ta.key" ''
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
    '';

    myanonamouseUpdate = pkgs.writeShellScript "myanonamouse-update" ''
      ${pkgs.coreutils}/bin/sleep 5
      ${pkgs.curl}/bin/curl -c /var/lib/openvpn-amsterdam/mam.cookies -b /var/lib/openvpn-amsterdam/mam.cookies https://t.myanonamouse.net/json/dynamicSeedbox.php > /dev/null 2>&1
    '';
  in {
    netns = "amsterdam";
    settings = {
      auth-user-pass = config.sops.secrets.perfect-privacy-password.path;
      client = true;
      dev-type = "tun";
      dev = "amsterdam";
      hand-window = 120;
      inactive = 604800;
      mute-replay-warnings = true;
      nobind = true;
      persist-key = true;
      persist-remote-ip = true;
      persist-tun = true;
      ping = 5;
      ping-restart = 120;
      redirect-gateway = "def1";
      remote-random = true;
      reneg-sec = 3600;
      resolv-retry = 60;
      route-delay = 2;
      route-method = "exe";
      script-security = 2;
      tls-cipher = "TLS_CHACHA20_POLY1305_SHA256:TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA:TLS_AES_256_GCM_SHA384:TLS-RSA-WITH-AES-256-CBC-SHA";
      tls-timeout = 5;
      verb = 4;

      tun-mtu = 1500;
      tun-mtu-extra = 32;
      mssfix = 1450;

      proto = "udp";

      remote = ["95.168.167.236 44" "95.168.167.236 443" "95.168.167.236 4433"];

      data-ciphers = "AES-256-GCM";
      auth = "SHA512";

      remote-cert-tls = "server";

      inherit ca cert tls-crypt;
      key = config.sops.secrets.perfect-privacy-openvpn-key.path;

      route-up = ''
        ${myanonamouseUpdate} &
      '';
    };
  };

  systemd.services.openvpn-amsterdam.serviceConfig.StateDirectory = "openvpn-amsterdam";

  sops.secrets = {
    perfect-privacy-password = {};
    perfect-privacy-openvpn-key = {};
  };
}
