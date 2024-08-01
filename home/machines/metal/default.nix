{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../devtools.nix
    ../../filebot.nix
    ../../firefox.nix
    ../../foot.nix
    ../../gpg.nix
    ../../gtk.nix
    ../../git.nix
    ../../media.nix
    ../../ncmpcpp.nix
    ../../pim.nix
    ../../shell.nix
    ../../ssh.nix
    ../../sway.nix
    ../../taskwarrior.nix
    ../../termshark.nix
    ../../wofi.nix
    ../../zathura.nix

    ./mpd.nix
    ./orpheus.nix
    ./photos.nix
    ./sway.nix
  ];

  home.packages = [
    pkgs.anki
    pkgs.tdesktop
    pkgs.calibre
    pkgs.tremc
    pkgs.virt-manager
    pkgs.libreoffice
    pkgs.picard
    pkgs.shntool
    pkgs.flac
    pkgs.cuetools
    pkgs.zeal
    pkgs.zoom-us

    pkgs.nixos-container
    pkgs.libvirt

    pkgs.pulseaudio
    pkgs.ncpamixer
    pkgs.bashmount

    pkgs.hunspellDicts.en_GB-large
    pkgs.hunspellDicts.ru_RU
  ];

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

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
      enable = true;
      defaultApplications = {
        "x-scheme-handler/tg" = ["org.telegram.desktop.desktop"];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
        "application/epub+zip" = ["org.pwmt.zathura.desktop"];
      };
    };
    userDirs.download = "${config.home.homeDirectory}/down";
  };
}
