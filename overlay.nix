final: prev: {
  p1-exporter = final.callPackage ./packages/p1-exporter { };

  restic = prev.restic.overrideAttrs (old: {
    patches = old.patches ++ [
      (prev.fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/restic/restic/pull/5356.diff";
        sha256 = "sha256-OGqGTDqfCvHUWWz/opzPqu4mMegJdBG9nVEXFP+mqpQ=";
      })
    ];
  });

  transmission_4 = prev.transmission_4.overrideAttrs (old: rec {
    version = "4.0.5";
    src = final.fetchFromGitHub {
      owner = "transmission";
      repo = "transmission";
      rev = version;
      hash = "sha256-gd1LGAhMuSyC/19wxkoE2mqVozjGPfupIPGojKY0Hn4=";
      fetchSubmodules = true;
    };
    patches = old.patches ++ [
      (prev.fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/transmission/transmission/pull/7089.diff";
        sha256 = "sha256-8CF9qvfiuutTpg5402APzbXf+9rLTFc9TlRJS9paLhc=";
      })
    ];
  });

  transmission-protonvpn-nat-pmp = final.callPackage ./packages/transmission-protonvpn-nat-pmp { };
}
