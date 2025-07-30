{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.devtools.lang.nix;
in
{
  options = {
    pbor.devtools.lang.nix.enable = (lib.mkEnableOption "Enable Nix") // {
      default = config.pbor.devtools.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      nil
      nixfmt-rfc-style
      nixfmt-tree
      nixpkgs-review
      nix-update
      nix-prefetch-github
      nix-prefetch-git
      nix-index
    ];
  };
}
