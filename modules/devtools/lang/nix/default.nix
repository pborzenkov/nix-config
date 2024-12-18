{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.devtools.lang.nix;
in {
  options = {
    pbor.devtools.lang.nix.enable = (lib.mkEnableOption "Enable Nix") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        nil
        alejandra
        nixpkgs-review
        nix-update
        nix-prefetch-github
        nix-prefetch-git
      ];
    };
  };
}
