{ ... }:
{
  systemd.services.syncthing = {
    unitConfig = {
      RequiresMountsFor = [ "/fast-storage" ];
    };
  };
}
