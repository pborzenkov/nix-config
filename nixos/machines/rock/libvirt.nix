{...}: {
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = ["mv-host"];
  };
  security.polkit.enable = true;
}
