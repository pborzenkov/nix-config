{ pkgs, ... }:
{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      HOMEHOST <system>
      MAILADDR root
      ARRAY /dev/md0 metadata=1.2 name=helios64:0 UUID=ac997842:6b5536ec:2343d40c:d7bd2ba9
    '';
  };

  fileSystems = {
    "/storage" = {
      device = "/dev/disk/by-uuid/d373e48c-8613-46e8-b2d5-18362bc91ebe";
      fsType = "ext4";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
        "data=writeback"
      ];
    };
    "/fast-storage" = {
      device = "fast-storage";
      fsType = "zfs";
    };
    "/new-storage" = {
      device = "storage";
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
