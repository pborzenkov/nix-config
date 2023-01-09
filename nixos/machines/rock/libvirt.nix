{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.libvirtd.enable = true;
  security.polkit.enable = true;

  systemd.services.libvirtd-config.script = lib.mkAfter ''
    rm -f /var/lib/libvirt/qemu/networks/autostart/default.xml
  '';
}
