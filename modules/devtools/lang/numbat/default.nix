{
  config,
  lib,
  ...
}:
let
  cfg = config.pbor.devtools.lang.numbat;
in
{
  options = {
    pbor.devtools.lang.numbat.enable = (lib.mkEnableOption "Enable numbat") // {
      default = config.pbor.devtools.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm = {
      programs.numbat = {
        enable = true;
        settings = {
          intro-banner = "short";
          prompt = "> ";
          exchange-rates.fetching-policy = "on-first-use";
        };
      };
    };
  };
}
