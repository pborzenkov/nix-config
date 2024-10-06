{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    config.boot.kernelPackages.perf
  ];

  programs = {
    adb.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
  users.users.pbor.extraGroups = ["adbusers" "wireshark"];
}
