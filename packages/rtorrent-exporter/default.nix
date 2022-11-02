{ lib, fetchFromGitHub, rustPlatform, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "rtorrent-exporter";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "rtorrent-exporter";
    rev = "v${version}";
    sha256 = "sha256-XRXvjbsepG9IhvOpXkgqFv3dnRjqR8u7qByLkVLERWc=";
  };

  cargoSha256 = "sha256-2Mm96001KFuAgthzvs4GdMjAj0dH9NNHVCEdHsoA9do=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "rtorrent-exporter - Prometheus exporter for RTorrent";
    homepage = "https://github.com/pborzenkov/rtorrent-exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ pborzenkov ];
  };
}
