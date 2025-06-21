{ ... }:
{
  networking = {
    hostName = "metal";
    domain = "lab.borzenkov.net";

    useDHCP = false;
    useNetworkd = true;

    nftables.enable = true;

    interfaces = {
      "enp8s0" = {
        useDHCP = true;
        wakeOnLan.enable = true;
      };
    };
  };
  services.resolved.enable = true;
  systemd.network.networks."40-enp8s0".dhcpV4Config.UseDomains = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id.indexOf("org.freedesktop.network1.") == 0) && subject.isInGroup("wheel")) {
        return polkit.Result.YES
      }
    });
  '';
}
