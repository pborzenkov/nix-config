{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../firefox.nix
    ../../foot.nix
    ../../gpg.nix
    ../../gtk.nix
    ../../git.nix
    ../../helix.nix
    ../../ncmpcpp.nix
    ../../pim.nix
    ../../shell.nix
    ../../ssh.nix
    ../../sway.nix
    ../../taskwarrior.nix
    ../../zathura.nix
    ../../zellij.nix
    ../../wofi.nix

    ./mpd.nix
    ./sway.nix
  ];

  home.packages = [
    pkgs.tdesktop
    pkgs.calibre
    pkgs.virt-manager
    # pkgs.libreoffice
    pkgs.jellyfin-media-player
    pkgs.slack
    pkgs.zeal
    pkgs.claws-mail
    # pkgs.google-chrome

    pkgs.pulseaudio
    pkgs.ncpamixer
    pkgs.bashmount
    pkgs.networkmanager_dmenu

    pkgs.hunspellDicts.en_GB-large
    pkgs.hunspellDicts.ru_RU
    pkgs.kubectl
    pkgs.teleport_12
  ];

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      pinentryFlavor = "gnome3";
    };
  };

  systemd.user.services.ssh-agent = {
    Install.WantedBy = ["default.target"];

    Unit = {
      Description = "SSH authentication agent";
      Documentation = "man:ssh-agent(1)";
    };

    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
    };
  };

  home = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      PATH = "\${HOME}/bin:\${PATH}";
      VIRSH_DEFAULT_CONNECT_URI = "qemu+ssh://rock.lab.borzenkov.net/system";
    };
    shellAliases = {
      mixer = "ncpamixer -t o";
      pmixer = "ncpamixer -t p";
    };
    file = {
      gtk-theme = {
        source = "${config.gtk.theme.package}/share/themes/base16";
        target = ".themes/base16";
      };

      nixpkgs = {
        source = inputs.nixpkgs;
        target = ".nix-defexpr/channels/nixpkgs";
      };
    };
  };

  wayland.windowManager.sway.config.window.commands = [
    {
      criteria = {app_id = "org.jellyfin.";};
      command = "inhibit_idle visible";
    }
  ];

  xdg = {
    configFile = {
      "networkmanager-dmenu/config.ini" = {
        text = (lib.generators.toINI {}) {
          dmenu = {
            dmenu_command = "wofi -d";
            pinentry = "pinentry-gnome3";
            format = "{name} {sec} {icon}";
            wifi_icons = "󰤟󰤢󰤥󰤨";
          };
        };
      };
      "wofi-power-menu.toml" = {
        source = (pkgs.formats.toml {}).generate "wofi-power-menu.toml" {
          wofi = {
            extra_args = "--width 20% --allow-markup --columns=1 --hide-scroll";
          };
          menu.hibernate.enabled = "false";
        };
      };
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
        "application/epub+zip" = ["org.pwmt.zathura.desktop"];
        "x-scheme-handler/http" = ["google-chrome.desktop"];
        "x-scheme-handler/https" = ["google-chrome.desktop"];
      };
    };
    userDirs.download = "${config.home.homeDirectory}/down";
    systemDirs.data = ["/home/pbor/.local/state/nix/profiles/profile/share"];
  };
}
