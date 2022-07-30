{ fetchurl, lib, stdenv, autoPatchelfHook, openssl }:

stdenv.mkDerivation rec {
  pname = "ankisyncd-rs";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/ankicommunity/anki-sync-server-rs/releases/download/${version}/ankisyncd_${version}_linux_x64.tar.gz";
    sha256 = "sha256-DIMlpoRHo7/bH+AyVyI3+inHRLtx/JETdhlIPJvaotc=";
  };

  buildInputs = [ openssl ];

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -D -m755 ankisyncd $out/bin/ankisyncd

    runHook postInstall
  '';
}
