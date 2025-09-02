{ ... }:
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      listenAddress = "192.168.111.8";
    };
  };
}
