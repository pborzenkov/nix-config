{
  fetchFromGitHub,
  python3Packages,
}:

let
  textfile-collector-scripts = fetchFromGitHub {
    owner = "prometheus-community";
    repo = "node-exporter-textfile-collector-scripts";
    rev = "b323e37c4bbcbb6d3579c4b4e0222306125ec9a4";
    sha256 = "sha256-25Tzs6kXA8R0EUIT9kOnuENGj5LMwru4oltaGSD+NSk=";
  };
in

python3Packages.buildPythonApplication rec {
  pname = "storcli-collector";
  version = "0.0.1";
  pyproject = false;

  propagatedBuildInputs = [
    python3Packages.prometheus-client
  ];

  dontUnpack = true;
  installPhase = ''
    install -Dm755 ${textfile-collector-scripts}/storcli.py $out/bin/${pname}
  '';
}
