{
  config,
  lib,
  ...
}: let
  cfg = config.pbor;
in {
  imports = [
    ./nix
    ./ssh
    ./sudo
    ./users
    ./virt
    ./wm
  ];

  options = {
    pbor.enable = (lib.mkEnableOption "Enable custom modules") // {default = true;};
  };

  config =
    lib.mkIf cfg.enable {
    };
}
