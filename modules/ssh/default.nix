{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.ssh;
in {
  options = {
    pbor.ssh.enable = (lib.mkEnableOption "Enable ssh") // {default = config.pbor.enable;};
    pbor.ssh.server.enable = (lib.mkEnableOption "Enable ssh server") // {default = cfg.enable && !isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = cfg.server.enable;
      openFirewall = true;
      settings = {
        LogLevel = "INFO";
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };

      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
    };

    hm.programs.ssh = {
      enable = true;

      matchBlocks = {
        "*" = {
          extraOptions = {
            HostKeyAlgorithms = lib.concatStringsSep "," [
              "ssh-ed25519-cert-v01@openssh.com"
              "ssh-rsa-cert-v01@openssh.com"
              "ssh-ed25519"
              "ssh-rsa"
            ];
            Ciphers = lib.concatStringsSep "," [
              "chacha20-poly1305@openssh.com"
              "aes256-gcm@openssh.com"
              "aes128-gcm@openssh.com"
              "aes256-ctr"
              "aes192-ctr"
              "aes128-ctr"
            ];
            KexAlgorithms = lib.concatStringsSep "," [
              "curve25519-sha256@libssh.org"
              "diffie-hellman-group-exchange-sha256"
            ];
            MACs = lib.concatStringsSep "," [
              "hmac-sha2-512-etm@openssh.com"
              "hmac-sha2-256-etm@openssh.com"
              "umac-128-etm@openssh.com"
              "hmac-sha2-512"
              "hmac-sha2-256"
              "umac-128@openssh.com"
            ];
          };
        };

        "rock rock.lab.borzenkov.net" = {
          forwardAgent = true;
          user = "pbor";
          remoteForwards = [
            {
              bind.address = "/run/user/1000/gnupg/S.gpg-agent";
              host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
            }
          ];
        };

        "helios64 helios64.lab.borzenkov.net" = {
          user = "pbor";
          forwardAgent = true;
        };

        "macos macos.lab.borzenkov.net" = {
          forwardAgent = true;
          extraOptions = {
            SetEnv = "TERM=screen-256color";
          };
        };

        "gw gw.lab.borzenkov.net" = {
          user = "pbor";
        };
      };

      includes = ["config.local"];
    };
  };
}
