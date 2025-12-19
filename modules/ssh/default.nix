{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.ssh;

  ssh-confirm = pkgs.writeShellApplication {
    name = "ssh-confirm";
    text = builtins.readFile ./scripts/ssh-confirm.sh;
    runtimeInputs = [ pkgs.wofi ];
  };
  ssh-rbw-askpass = pkgs.writeShellApplication {
    name = "ssh-rbw-askpass";
    text = builtins.readFile ./scripts/ssh-rbw-askpass.sh;
    runtimeInputs = [
      pkgs.nettools
      pkgs.rbw
    ];
  };
  ssh-add-key = pkgs.writeShellApplication {
    name = "ssh-add-key";
    text = builtins.readFile ./scripts/ssh-add-key.sh;
    runtimeInputs = [
      pkgs.openssh
      ssh-rbw-askpass
    ];
  };
in
{
  options = {
    pbor.ssh.enable = (lib.mkEnableOption "Enable ssh") // {
      default = config.pbor.enable;
    };
    pbor.ssh.server.enable = (lib.mkEnableOption "Enable ssh server") // {
      default = cfg.enable && !isDesktop;
    };
    pbor.ssh.server.openFirewall = lib.mkOption {
      type = lib.types.bool;
      description = ''
        Open firewall for OpenSSH
      '';
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = cfg.server.enable;
      openFirewall = cfg.server.openFirewall;
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
        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "no";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";

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

          "macos macos.lab.borzenkov.net" = {
            forwardAgent = true;
            extraOptions = {
              SetEnv = "TERM=screen-256color";
            };
          };

          "gw gw.lab.borzenkov.net" = {
            user = "pbor";
          };

          "*.mk.lab.borzenkov.net" = {
            user = "admin";
          };
        };

        includes = [ "config.local" ];
      };
      home = {
        packages = [ ssh-add-key ];
        sessionVariables = lib.mkIf isDesktop {
          SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
        };
      };

      systemd.user.services.ssh-agent = lib.mkIf isDesktop {
        Unit = {
          After = [ "graphical-session.target" ];
        };

        Service = {
          Type = "exec";
          ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
          Environment = "SSH_ASKPASS=${ssh-confirm}/bin/ssh-confirm";
          Restart = "on-failure";
          Slice = "background-graphical.slice";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
