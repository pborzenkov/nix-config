{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.devtools.networking;
in {
  options = {
    pbor.devtools.networking.enable = (lib.mkEnableOption "Enable networking tools") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    users.users.pbor.extraGroups = ["wireshark"];

    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        hurl
        oha
        xh
        gron
        trippy
        curl
        q
        tcpdump
      ];
    };
  };
}
