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
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          runAsRoot = false;
          vhostUserPackages = [
            pkgs.virtiofsd
          ];
        };
      };
      podman = {
        enable = true;
        autoPrune = {
          enable = true;
          flags = ["--all"];
        };
        dockerCompat = true;
        dockerSocket.enable = true;
      };
    };
    users.users.pbor.extraGroups = ["kvm" "podman" "libvirtd"];

    hm = {config, ...}: {
      home = {
        packages = with pkgs; [
          libvirt
          virt-manager
          nixos-container
        ];
      };
    };
  };
}
