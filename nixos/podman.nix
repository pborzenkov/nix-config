{
  config,
  pkgs,
  ...
}: {
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
}
