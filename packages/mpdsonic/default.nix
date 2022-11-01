{ lib, fetchFromGitHub, rustPlatform, libnfs, openssl, pkg-config }:

let
  libnfs-pthread = libnfs.overrideAttrs (old: {
    configureFlags = [ "--enable-pthread" ];
    patches = [
      ./libnfs-fix.diff
    ];
  });
in
rustPlatform.buildRustPackage rec {
  pname = "mpdsonic";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "mpdsonic";
    rev = "v${version}";
    sha256 = "sha256-Q6RtGELVWIUnlb/XMMmHtyUpcnt/aqMirlJIdWwlZU4=";
  };

  cargoSha256 = "sha256-8XZ0UMcgzYwSG8v64E2LsL9ZX18fC0q2HDpAoZxHIFY=";

  nativeBuildInputs = [ pkg-config rustPlatform.bindgenHook ];

  buildInputs = [ libnfs-pthread openssl ];

  meta = with lib; {
    description = "mpdsonic - expose MPD library via Subsonic protocol";
    homepage = "https://github.com/pborzenkov/mpdsonic";
    license = licenses.mit;
    maintainers = with maintainers; [ pborzenkov ];
  };
}
