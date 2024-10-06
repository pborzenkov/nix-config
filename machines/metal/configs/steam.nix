{...}: {
  networking = {
    firewall = {
      allowedTCPPorts = [
        27036 # Steam
      ];
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27035;
        } # Steam
      ];
    };
  };
}
