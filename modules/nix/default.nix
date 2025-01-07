{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.nix;

  nixpkgsPath = "/etc/nixpkgs/channels/nixpkgs";
in {
  options = {
    pbor.nix.enable = (lib.mkEnableOption "Enable nix") // {default = config.pbor.enable;};
  };

  config = lib.mkIf cfg.enable {
    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = ''
        keep-outputs = true
        keep-derivations = true
        experimental-features = nix-command flakes
      '';

      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };

      settings = let
        subs = [
          "https://nix-community.cachix.org"
          "https://pborzenkov.cachix.org"
        ];
      in {
        trusted-users = [
          "root"
          "@wheel"
        ];

        auto-optimise-store = true;

        substituters = subs;
        trusted-substituters = subs;
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "pborzenkov.cachix.org-1:ffVB/S9v4T+PecDRk83gPmbWnVQpjRc76k6bGtnk6YM="
        ];
      };

      registry = {
        nixpkgs.flake = inputs.nixpkgs;
      };

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath} - - - - ${inputs.nixpkgs}"
    ];

    hm.nix.gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };
}
