{ ... }:
{
  systemd.services.syncthing = {
    unitConfig = {
      RequiresMountsFor = [ "/storage" ];
    };
  };
}
