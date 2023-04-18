{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  openssl,
}:
stdenv.mkDerivation rec {
  pname = "ankisyncd-rs";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/ankicommunity/anki-sync-server-rs/releases/download/${version}/ankisyncd_${version}_linux_x64.tar.gz";
    sha256 = "sha256-srsL7gV0ov1yn/Ix8Kh0vrBXoN9p74Pi8NEVHZeNwiM=";
  };

  buildInputs = [openssl stdenv.cc.cc.libgcc or null];

  nativeBuildInputs = [autoPatchelfHook];

  installPhase = ''
    runHook preInstall

    install -D -m755 ankisyncd $out/bin/ankisyncd

    runHook postInstall
  '';
}
