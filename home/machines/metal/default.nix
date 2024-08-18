{pkgs, ...}: {
  imports = [
    ../../media.nix
    ../../pim.nix
    ../../ssh.nix
    ../../sway.nix
    ../../taskwarrior.nix

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
    wm.i3status.sound_mappings = {
      "alsa_output.usb-Razer_Razer_USB_Sound_Card_00000000-00.analog-stereo" = "";
      "alsa_output.pci-0000_12_00.4.analog-stereo" = "";
      "alsa_output.pci-0000_10_00.1.hdmi-stereo-extra4" = "";
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
    pkgs.zoom-us

    pkgs.nixos-container
    pkgs.libvirt

    pkgs.bashmount
  ];

  home = {
    sessionVariables = {
      VIRSH_DEFAULT_CONNECT_URI = "qemu+ssh://rock.lab.borzenkov.net/system";
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
