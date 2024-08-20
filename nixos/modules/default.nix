{
  config,
  lib,
  ...
}: let
  cfg = config.pbor;
in {
  imports = [
    ./nix
    ./openssh
    ./sudo
    ./users
    ./virt
  ];

  options = {
    pbor.enable = (lib.mkEnableOption "Enable custom modules") // {default = true;};
  };

  config =
    lib.mkIf cfg.enable {
    };
}
