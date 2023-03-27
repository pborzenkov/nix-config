{lib, ...}: {
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = ["mv-host"];
  };
  security.polkit.enable = true;

  systemd.services.libvirtd-config.script = lib.mkAfter ''
    rm -f /var/lib/libvirt/qemu/networks/autostart/default.xml
  '';
}
