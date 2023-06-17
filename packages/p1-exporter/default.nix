{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "p1-exporter";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "p1-exporter";
    rev = "v${version}";
    sha256 = "sha256-7P+NsHp0HuykR6nmPmvB3n+8LQi2p6b66qQwD77TeJk=";
  };

  cargoSha256 = "sha256-MYYdrWCzogNtT+7C0UXOgkK6/NXn1L2eVfJLn7LqYrc=";

  meta = with lib; {
    description = "Prometheus exporter for DSMR reader with serial over TCP";
    homepage = "https://github.com/pborzenkov/p1-exporter";
    license = licenses.mit;
    maintainers = with maintainers; [pborzenkov];
  };
}
