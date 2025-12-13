{ ... }:
{
  services.tinyproxy = {
    enable = true;
    settings = {
      Listen = "192.168.111.2";
      Port = 8888;
    };
  };
  systemd.services.tinyproxy = {
    after = [ "systemd-networkd-wait-online@wg0.service" ];
    requires = [ "systemd-networkd-wait-online@wg0.service" ];
  };
}
