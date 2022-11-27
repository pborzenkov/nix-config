{ fetchurl, stdenv, autoPatchelfHook, openssl }:

stdenv.mkDerivation rec {
  pname = "ankisyncd-rs";
  version = "0.2.6";

  src = fetchurl {
    url = "https://github.com/ankicommunity/anki-sync-server-rs/releases/download/${version}/ankisyncd_${version}_linux_x64.tar.gz";
    sha256 = "9b29ae449b8091a0c051f74694b56e2e70ae7a2cf65dcc42db8400a973315d8a";
  };

  buildInputs = [ openssl ];

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -D -m755 ankisyncd $out/bin/ankisyncd

    runHook postInstall
  '';
}
