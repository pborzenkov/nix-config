{pkgs, ...}: {
  pbor = {
    basetools = {
      jq.enable = false;
      pass.enable = false;
      restic.enable = false;
      ripgrep.all.enable = false;
    };
    filebot.enable = false;
    gpg.enable = false;
    syncthing.enable = false;
  };

  boot = {
    loader.grub = {
      enable = true;
      configurationLimit = 3;
      devices = ["/dev/vda"];
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  time.timeZone = "Europe/Amsterdam";
}
