{ pkgs, ... }:
{
  fileSystems = {
    "/storage" = {
      device = "storage";
      fsType = "zfs";
    };
    "/fast-storage" = {
      device = "fast-storage";
      fsType = "zfs";
    };
  };

  users.groups.storage = {
    gid = 1000;
    members = [
      "pbor"
      "nobody"
    ];
  };

  boot.zfs.package = pkgs.zfs_2_4;
  services = {
    nfs.server = {
      enable = true;
      exports = ''
        /storage *(rw,insecure,sync,no_subtree_check,all_squash,anonuid=65534,anongid=1000)
      '';
    };
    zfs = {
      autoScrub = {
        enable = true;
        pools = [ "fast-storage" ];
      };
      trim.enable = true;
    };
  };
  networking = {
    hostId = "dcf46265";
    firewall.allowedTCPPorts = [ 2049 ];
  };

  pbor.webapps.apps.storage = {
    subDomain = "storage";
    locations = {
      "/" = {
        custom = {
          root = "/storage";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
  };
}
