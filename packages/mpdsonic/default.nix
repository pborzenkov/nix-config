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
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "mpdsonic";
    rev = "v${version}";
    sha256 = "sha256-zVo4STa2bWWhLu85lWpwrGPTYDTEhwnAU+l9gvcjhBY=";
  };

  cargoSha256 = "sha256-fEes9SY4v7v56UGKXUBZLpXibbT6JsOTmC2uRAbbaHA=";

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
