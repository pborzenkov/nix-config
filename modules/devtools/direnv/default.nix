{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.devtools.direnv;
in
{
  options = {
    pbor.devtools.direnv.enable = (lib.mkEnableOption "Enable direnv") // {
      default = config.pbor.devtools.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    services.angrr = {
      enable = true;
      package = pkgs.unstable.angrr;
      enableNixGcIntegration = true;
      settings = {
        temporary-root-policies = {
          direnv = {
            path-regex = "/\\.direnv/";
            period = "14d";
          };
          result = {
            path-regex = "/result[^/]*$";
            period = "3d";
          };
        };
      };
    };
    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv = {
        enable = true;
      };
      angrr = {
        enable = true;
        autoUse = true;
      };
    };
  };
}
