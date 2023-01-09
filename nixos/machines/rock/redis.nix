{
  config,
  pkgs,
  ...
}: {
  services.redis.servers."" = {
    enable = true;
  };
}
