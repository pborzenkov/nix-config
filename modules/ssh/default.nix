{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.ssh;

  rbw-ssh-askpass = pkgs.writeShellApplication {
    name = "rbw-ssh-askpass";
    text = builtins.readFile ./scripts/rbw-ssh-askpass.sh;
    runtimeInputs = [pkgs.nettools pkgs.rbw pkgs.wofi];
  };
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

    hm = {
      programs.ssh = {
        enable = true;
        addKeysToAgent = "confirm";

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
            user = "pbor";
            forwardAgent = true;
          };

          "helios64 helios64.lab.borzenkov.net" = {
            user = "pbor";
            forwardAgent = true;
            extraOptions = {
              SetEnv = "TERM=screen-256color";
            };
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
      home.sessionVariables = lib.mkIf isDesktop {
        SSH_ASKPASS_REQUIRE = "prefer";
        SSH_ASKPASS = "${rbw-ssh-askpass}/bin/rbw-ssh-askpass";
        SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
      };

      systemd.user.services.ssh-agent = lib.mkIf isDesktop {
        Unit = {
          After = ["graphical-session.target"];
        };

        Service = {
          Type = "exec";
          ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
          Environment = "SSH_ASKPASS=${rbw-ssh-askpass}/bin/rbw-ssh-askpass";
          Restart = "on-failure";
          Slice = "background-graphical.slice";
        };

        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
