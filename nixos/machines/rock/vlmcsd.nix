{
  config,
  pkgs,
  nur,
  ...
}: {
  imports = [
    nur.repos.pborzenkov.modules.vlmcsd
  ];

  services.vlmcsd = {
    enable = true;
    disconnectClients = true;
    openFirewall = true;
  };
}
