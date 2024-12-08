{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "p1-exporter";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "p1-exporter";
    rev = "v${version}";
    sha256 = "sha256-D8jaQvgCcEhy81Zl4BNh401/sQuG6/Z7E73fXZxbrhU=";
  };

  cargoHash = "sha256-p++EIbosvAPqZ4ASW7smsyhJTQFCniJH3LrDmWcnsoA=";

  meta = with lib; {
    description = "Prometheus exporter for DSMR reader with serial over TCP";
    homepage = "https://github.com/pborzenkov/p1-exporter";
    license = licenses.mit;
    maintainers = with maintainers; [pborzenkov];
  };
}
