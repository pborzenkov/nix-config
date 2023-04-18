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

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "nfs-0.1.0" = "sha256-By0Crtggzd6RqKpBjTRtqvk7DbqQQa1QqxWU2TSuRqk=";
    };
  };

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
