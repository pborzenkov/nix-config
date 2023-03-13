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
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "mpdsonic";
    rev = "v${version}";
    sha256 = "sha256-ghLX4l74zl3uITGN6w+qtU1lWA7aXU1B+1Fv/TXAT6o=";
  };

  cargoSha256 = "sha256-7DXKXfAvZ1OoEdMKaT4/JNutG8hy8ufvY++TbkIGT00=";

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
