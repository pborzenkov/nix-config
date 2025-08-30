{
  ...
}:

{
  pbor = {
    basetools = {
      jq.enable = false;
      restic.enable = false;
      ripgrep.all.enable = false;
    };
    filebot.enable = false;
    syncthing.enable = false;
    ssh.server.openFirewall = false;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  time.timeZone = "Europe/Amsterdam";
}
