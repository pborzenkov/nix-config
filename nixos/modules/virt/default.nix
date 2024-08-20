{
  config,
  lib,
  isDesktop,
  ...
}: let
  cfg = config.pbor.virt;
in {
  options = {
    pbor.virt.enable = (lib.mkEnableOption "Enable virt") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = ["--all"];
      };
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };
}
