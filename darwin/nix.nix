{
  config,
  pkgs,
  ...
}: {
  nix = {
    configureBuildUsers = true;
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

    settings = {
      allowed-users = [
        "@admin"
      ];

      substituters = [
        "https://nix-community.cachix.org"
        "https://pborzenkov.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "pborzenkov.cachix.org-1:ffVB/S9v4T+PecDRk83gPmbWnVQpjRc76k6bGtnk6YM="
      ];
    };
  };
}
