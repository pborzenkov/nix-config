{ fetchurl, stdenv, autoPatchelfHook, openssl }:

stdenv.mkDerivation rec {
  pname = "ankisyncd-rs";
  version = "0.1.9";

  src = fetchurl {
    url = "https://github.com/ankicommunity/anki-sync-server-rs/releases/download/0.1.9/ankisyncd_0.1.9_linux_x86_64_glibc.tar.gz";
    sha256 = "sha256-D9cFqxbTIZd4vXMwb0QM1137vyHQf9h8XCBdcym/M5A=";
  };

  buildInputs = [ openssl ];

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -D -m755 ankisyncd $out/bin/ankisyncd

    runHook postInstall
  '';
}
