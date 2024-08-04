{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.basetools;
in {
  imports = [
    ./bat
    ./fd
    ./htop
    ./jq
    ./pass
    ./restic
    ./ripgrep
    ./skim
    ./zoxide
  ];

  options = {
    pbor.basetools.enable = (lib.mkEnableOption "Enable basetools") // {default = config.pbor.enable;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      moreutils
      findutils
      file
      bc
      zip
      unzip
      unrar
      usbutils
      pciutils
      sd
      unstable.md-tui
      iproute2
      sqlite
    ];
  };

  # TODO: md-tui configuration
}
