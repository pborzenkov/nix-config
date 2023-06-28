{
  pkgs,
  inputs,
  ...
}: let
  nixpkgsPath = "/etc/nixpkgs/channels/nixpkgs";
in {
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
        "https://devenv.cachix.org"
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
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    nixPath = [
      "nixpkgs=${nixpkgsPath}"
    ];
  };

  systemd.tmpfiles.rules = [
    "L+ ${nixpkgsPath} - - - - ${inputs.nixpkgs}"
  ];
}
