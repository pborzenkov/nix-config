final: prev: {
  fan2go = prev.fan2go.overrideAttrs (old: {
    name = "fan2go";
    patches = (old.patches or [ ]) ++ [ ./patches/fan2go-get-pwm.diff ];
  });

  framework-tool = prev.framework-tool.overrideAttrs (old: rec {
    name = "framework-tool";
    version = "2fefd3789948b90e77e5c2048633f8b4c12b008d";

    src = final.fetchFromGitHub {
      owner = "FrameworkComputer";
      repo = "framework-system";
      rev = "2fefd3789948b90e77e5c2048633f8b4c12b008d";
      hash = "sha256-4nNEeCjpJPY1dRpAVXNgrhtcLy3rSCLNGRB1mLmgilo=";
    };

    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-KhEU9TfDsaOZfXpBfP2jGNLuCNVwJsiCVCPnGJGTI3A=";
    };
  });

  p1-exporter = final.callPackage ./packages/p1-exporter { };

  storcli-collector = final.callPackage ./packages/storcli-collector { };

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
