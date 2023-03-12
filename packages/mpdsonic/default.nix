{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libnfs,
  openssl,
  pkg-config,
  withNFS ? false,
}:
rustPlatform.buildRustPackage rec {
  pname = "mpdsonic";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "mpdsonic";
    rev = "v${version}";
    sha256 = "sha256-JeFUHAIfcshQ8ZAPfAlzdWr++jHNMV9ASSVcBwDmoN0=";
  };

  cargoSha256 = "sha256-oGJviSTtejk8XozohklSgzFeq9zynN1y+6N2GKTcTig=";

  nativeBuildInputs = [pkg-config] ++ lib.optionals withNFS [rustPlatform.bindgenHook];
  buildInputs = [openssl] ++ lib.optionals withNFS [libnfs];

  buildFeatures = lib.optional withNFS "nfs";

  meta = with lib; {
    description = "mpdsonic - expose MPD library via Subsonic protocol";
    homepage = "https://github.com/pborzenkov/mpdsonic";
    license = licenses.mit;
    maintainers = with maintainers; [pborzenkov];
  };
}
