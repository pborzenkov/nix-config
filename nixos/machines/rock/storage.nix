{
  config,
  pkgs,
  ...
}: {
  fileSystems."/storage" = {
    device = "helios64.lab.borzenkov.net:/storage";
    fsType = "nfs";
  };

  webapps.apps.storage = {
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
