{
  fetchurl,
  stdenv,
  autoPatchelfHook,
  openssl,
}:
stdenv.mkDerivation rec {
  pname = "ankisyncd-rs";
  version = "1.1.3";

  src = fetchurl {
    url = "https://github.com/ankicommunity/anki-sync-server-rs/releases/download/${version}/ankisyncd_${version}_linux_x64.tar.gz";
    sha256 = "sha256-z5aq1EGSfa4ZjMOLLu6p/6cjcWRTwNptyfDNpQIDALY=";
  };

  buildInputs = [openssl stdenv.cc.cc.libgcc or null];

  nativeBuildInputs = [autoPatchelfHook];

  installPhase = ''
    runHook preInstall

    install -D -m755 ankisyncd $out/bin/ankisyncd

    runHook postInstall
  '';
}
