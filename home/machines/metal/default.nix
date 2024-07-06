{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../basetools.nix
    ../../devtools.nix
    ../../filebot.nix
    ../../firefox.nix
    ../../foot.nix
    ../../gpg.nix
    ../../gtk.nix
    ../../git.nix
    ../../helix.nix
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
    ../../zellij.nix

    ./mpd.nix
    ./orpheus.nix
    ./photos.nix
    ./sway.nix
  ];

  home.packages = let
    anki = pkgs.writeScriptBin "anki" ''
      export ANKI_WAYLAND=1
      exec ${pkgs.anki-bin}/bin/anki
    '';
  in [
    anki
    pkgs.tdesktop
    pkgs.calibre
    pkgs.tremc
    pkgs.virt-manager
    pkgs.libreoffice
    pkgs.picard
    pkgs.shntool
    pkgs.flac
    pkgs.cuetools
    pkgs.slack
    pkgs.zeal
    pkgs.claws-mail
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
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      PATH = "\${HOME}/bin:\${PATH}";
      VIRSH_DEFAULT_CONNECT_URI = "qemu+ssh://rock.lab.borzenkov.net/system";
    };
    shellAliases = {
      mixer = "ncpamixer -t o";
      pmixer = "ncpamixer -t p";
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
