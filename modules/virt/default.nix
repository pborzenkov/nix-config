{
  config,
  lib,
  pkgs,
  isDesktop,
  username,
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
    users.users.pbor.extraGroups = ["podman"];

    home-manager.users."${username}" = {
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
  };
}
