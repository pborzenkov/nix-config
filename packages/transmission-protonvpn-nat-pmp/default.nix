{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "transmission-protonvpn-nat-pmp";
  version = "0.1.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit rev;

    owner = "pborzenkov";
    repo = "transmission-protonvpn-nat-pmp";
    sha256 = "sha256-pCXmWXU780bnApFEjCtzOBV/n+tzFtHr6Eu+1MLpwVo=";
  };

  vendorHash = "sha256-WbDZ0yn15gzD90Dl+kSuHcMvzdm44XzZlJiGylc++9o=";

  meta = with lib; {
    description = "A tool to request an external port from ProtonVPN and configure Transmission to use it";
    homepage = "https://github.com/pborzenkov/transmission-protonvpn-nat-pmp";
    license = with licenses; [mit];
    maintainers = with maintainers; [pborzenkov];
  };
}
