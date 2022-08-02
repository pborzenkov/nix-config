{ lib, fetchFromGitHub, rustPlatform, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "mpdsonic";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "mpdsonic";
    rev = "v${version}";
    sha256 = "sha256-mTl3nataosfh+iq7M3jZMTwNTX4bj9815MDfFdFPF5s=";
  };

  cargoSha256 = "sha256-poFLNYt8a7yHaMdDJs4b0s3NP5VKE8W/bvuryE8T34Y=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "mpdsonic - expose MPD library via Subsonic protocol";
    homepage = "https://github.com/pborzenkov/mpdsonic";
    license = licenses.mit;
    maintainers = with maintainers; [ pborzenkov ];
  };
}
