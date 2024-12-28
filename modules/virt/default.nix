{
  config,
  lib,
  pkgs,
  isDesktop,
  username,
  ...
}: let
  cfg = config.pbor.virt;
in {
  options = {
    pbor.virt.enable = (lib.mkEnableOption "Enable virt") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = ["--all"];
      };
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    users.users.pbor.extraGroups = ["kvm" "podman"];

    home-manager.users."${username}" = {config, ...}: {
      home = {
        packages = with pkgs; [
          libvirt
          virt-manager
          nixos-container
          nemu
        ];

        sessionVariables = {
          VIRSH_DEFAULT_CONNECT_URI = "qemu+ssh://rock.lab.borzenkov.net/system";
        };
      };

      xdg.configFile."nemu/nemu.cfg".text = lib.generators.toINI {} {
        main = {
          vmdir = "/mnt/dump/vms";
          db = "${config.xdg.dataHome}/nemu/nemu.db";
        };
        viewer = {
          spice_default = 1;
          vnc_bin = "${pkgs.tigervnc}/bin/vncviewer";
          vnc_args = ":%p";
          spice_bin = "${pkgs.spice-gtk}/bin/spicy";
          spice_args = "--title %t --host 127.0.0.1 --port %p";
          listen_any = 0;
        };
        qemu = {
          qemu_bin_path = "${pkgs.qemu}/bin";
          targets = "x86_64,i386";
          enable_log = 1;
          log_cmd = "/tmp/qemu_last_cmd.log";
        };
        nemu-monitor = {
          autostart = 1;
          pid = "/tmp/nemu-monitor.pid";
          dbus_enabled = 1;
        };
      };
    };
  };
}
