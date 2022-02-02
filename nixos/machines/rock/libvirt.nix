{ config, pkgs, lib, ... }:

{
  virtualisation.libvirtd.enable = true;

  systemd.services.libvirtd-config.script = lib.mkAfter ''
    rm /var/lib/libvirt/qemu/networks/autostart/default.xml
  '';
}
