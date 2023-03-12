final: prev: {
  ankisyncd-rs = final.callPackage ./packages/ankisyncd-rs {};

  mpdsonic = final.callPackage ./packages/mpdsonic {};

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

  rtorrent-exporter = final.callPackage ./packages/rtorrent-exporter {};

  transmission = final.callPackage ./packages/transmission {};
}
