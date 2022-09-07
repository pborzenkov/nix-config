{ lib, fetchFromGitHub, rustPlatform, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "mpdsonic";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "mpdsonic";
    rev = "v${version}";
    sha256 = "sha256-pFW/2nX4ui42RDdro2pa7rWI4sh+TduQLjkV6AbBQtU=";
  };

  cargoSha256 = "sha256-1nuanZarniQiKqUUsG5FfIPbPoD+X85wRgHCrP6zD/Q=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "mpdsonic - expose MPD library via Subsonic protocol";
    homepage = "https://github.com/pborzenkov/mpdsonic";
    license = licenses.mit;
    maintainers = with maintainers; [ pborzenkov ];
  };
}
