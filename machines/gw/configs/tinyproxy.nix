{...}: {
  services.tinyproxy = {
    enable = true;
    settings = {
      Listen = "192.168.111.2";
      Port = 8888;
    };
  };
}
