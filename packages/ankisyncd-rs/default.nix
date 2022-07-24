{ fetchurl, stdenv, autoPatchelfHook, openssl }:

stdenv.mkDerivation rec {
  pname = "ankisyncd-rs";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/ankicommunity/anki-sync-server-rs/releases/download/${version}/ankisyncd_${version}_linux_x64.tar.gz";
    sha256 = "sha256-JPzYRPx2/Grf7/4oDK0q9Q0oQgN8DOkTZ0277D7H+Nc=";
  };

  buildInputs = [ openssl ];

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -D -m755 ankisyncd $out/bin/ankisyncd

    runHook postInstall
  '';
}
