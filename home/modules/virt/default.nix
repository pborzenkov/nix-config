{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}: let
  cfg = config.pbor.virt;
in {
  options = {
    pbor.virt.enable = (lib.mkEnableOption "Enable virt") // {default = config.pbor.enable && isDesktop;};
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        libvirt
        virt-manager
        nixos-container
      ];

      sessionVariables = {
        VIRSH_DEFAULT_CONNECT_URI = "qemu+ssh://rock.lab.borzenkov.net/system";
      };
    };
  };
}
