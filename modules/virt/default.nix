{
  config,
  lib,
  pkgs,
  isDesktop,
  ...
}:
let
  cfg = config.pbor.virt;
in
{
  options = {
    pbor.virt.enable = (lib.mkEnableOption "Enable virt") // {
      default = config.pbor.enable && isDesktop;
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: for rootless podman (https://github.com/nikstur/userborn/issues/7)
    environment.etc =
      let
        autosubs = lib.pipe config.users.users [
          lib.attrValues
          (lib.filter (u: u.uid != null && u.isNormalUser))
          (lib.concatMapStrings (u: "${toString u.uid}:${toString (100000 + u.uid * 65536)}:65536\n"))
        ];
      in
      {
        "subuid".text = autosubs;
        "subuid".mode = "0444";
        "subgid".text = autosubs;
        "subgid".mode = "0444";
      };
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
          flags = [ "--all" ];
        };
        dockerCompat = true;
        dockerSocket.enable = true;
      };
    };
    users.users.pbor.extraGroups = [
      "kvm"
      "podman"
      "libvirtd"
    ];

    hm =
      { config, ... }:
      {
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
