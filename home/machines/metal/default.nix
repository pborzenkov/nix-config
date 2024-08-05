{pkgs, ...}: {
  imports = [
    ../../filebot.nix
    ../../media.nix
    ../../ncmpcpp.nix
    ../../pim.nix
    ../../ssh.nix
    ../../sway.nix
    ../../taskwarrior.nix

    ./mpd.nix
    ./orpheus.nix
    ./photos.nix
    ./sway.nix
  ];

  pbor = {
    wofi.menu = {
      windows = {
        title = "Reboot to Windows";
        cmd = "sudo systemctl reboot --boot-loader-entry auto-windows";
        icon = "";
      };
    };

    devtools = {
      lang.c.enable = true;
    };
  };

  home.packages = [
    pkgs.anki
    pkgs.tdesktop
    pkgs.calibre
    pkgs.unstable.stig
    pkgs.virt-manager
    pkgs.libreoffice
    pkgs.picard
    pkgs.shntool
    pkgs.flac
    pkgs.cuetools
    pkgs.zoom-us
    pkgs.handbrake
    pkgs.mkvtoolnix

    pkgs.nixos-container
    pkgs.libvirt

    pkgs.pulseaudio
    pkgs.ncpamixer
    pkgs.bashmount

    pkgs.hunspellDicts.en_GB-large
    pkgs.hunspellDicts.ru_RU
  ];

  home = {
    sessionVariables = {
      VIRSH_DEFAULT_CONNECT_URI = "qemu+ssh://rock.lab.borzenkov.net/system";
    };
    shellAliases = {
      unflac = ''${pkgs.unflac}/bin/unflac -n "{{.Input.Artist | Elem}} - {{with .Input.Title}}{{. | Elem}}{{else}}Unknown Album{{end}} ({{- with .Input.Date}}{{.}}{{end}})/ {{- printf .Input.TrackNumberFmt .Track.Number}} - {{.Track.Title | Elem}}"'';
    };
  };

  xdg = {
    mimeApps = {
      defaultApplications = {
        "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
      };
    };
  };
}
