final: prev: {
  mujmap = prev.mujmap.overrideAttrs (old: rec {
    name = "mujmap-696cc8673f2f6a80e3bdf878cb2a8efc44d455c8";
    version = "696cc8673f2f6a80e3bdf878cb2a8efc44d455c8";
    src = final.fetchFromGitHub {
      owner = "elizagamedev";
      repo = "mujmap";
      rev = "696cc8673f2f6a80e3bdf878cb2a8efc44d455c8";
      sha256 = "sha256-gxx3U5/BTRr7rRpaa1LcWGfy6tqHIh7l1MiFP8MWkKs=";
    };
    cargoDeps = old.cargoDeps.overrideAttrs (final.lib.const {
      name = "${name}-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-xO73kP0ACPfMZnDEj9Np+wwtxFyfOYDX4To2wBReKZo=";
    });
  });

  p1-exporter = final.callPackage ./packages/p1-exporter {};

  transmission_4 = prev.transmission_4.overrideAttrs (old: rec {
    version = "4.0.5";
    src = final.fetchFromGitHub {
      owner = "transmission";
      repo = "transmission";
      rev = version;
      hash = "sha256-gd1LGAhMuSyC/19wxkoE2mqVozjGPfupIPGojKY0Hn4=";
      fetchSubmodules = true;
    };
    patches =
      old.patches
      ++ [
        (prev.fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/transmission/transmission/pull/7089.diff";
          sha256 = "sha256-8CF9qvfiuutTpg5402APzbXf+9rLTFc9TlRJS9paLhc=";
        })
      ];
  });

  transmission-protonvpn-nat-pmp = final.callPackage ./packages/transmission-protonvpn-nat-pmp {};
}
