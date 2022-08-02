{ lib, fetchFromGitHub, rustPlatform, openssl, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "mpdsonic";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "mpdsonic";
    rev = "v${version}";
    sha256 = "sha256-Jdspn8t9BnWZ4UKYWMRz+dGUjoBogrNP7nnDg9uaFpM=";
  };

  cargoSha256 = "sha256-6HHVZGZYcOtdeUvZexHTaZGgj7qMqh2F3X6HZzgIhdU=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "mpdsonic - expose MPD library via Subsonic protocol";
    homepage = "https://github.com/pborzenkov/mpdsonic";
    license = licenses.mit;
    maintainers = with maintainers; [ pborzenkov ];
  };
}
