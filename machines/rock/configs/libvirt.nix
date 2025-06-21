{ ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "mv-host" ];
  };
  security.polkit.enable = true;

  users.users.pbor.extraGroups = [ "libvirtd" ];
}
