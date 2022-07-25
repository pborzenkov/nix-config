{ lib, fetchFromGitHub, rustPlatform, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "mpdsonic";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "mpdsonic";
    rev = "v${version}";
    sha256 = "sha256-C5yT855w8Vbg0xAmvFdpn2X3/TT2nqvH+X0CXZ6hebA=";
  };

  cargoSha256 = "sha256-SKybrRpnXaLwcnqVVoOD9klxvvLcgeGRsN6bazOc8KU=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "mpdsonic - expose MPD library via Subsonic protocol";
    homepage = "https://github.com/pborzenkov/mpdsonic";
    license = licenses.mit;
    maintainers = with maintainers; [ pborzenkov ];
  };
}
