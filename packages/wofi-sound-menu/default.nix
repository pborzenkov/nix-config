{
  stdenv,
  lib,
  pulseaudio,
  jq,
  wofi,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "wofi-sound-menu";
  version = "0.1";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = ./wofi-sound-menu.sh;
  };
  nativeBuildInputs = [makeWrapper];
  postInstall = ''
    mkdir -p $out/bin
    install -m 755 wofi-sound-menu.sh $out/bin/wofi-sound-menu
    wrapProgram $out/bin/wofi-sound-menu \
      --prefix PATH : ${lib.makeBinPath [pulseaudio jq wofi]}
  '';
}
