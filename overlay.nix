final: prev:

{
  calibre = prev.calibre.override {
    python3Packages = prev.python3Packages.overrideScope (self: super: {
      # remove after #168071 is merged
      apsw = super.apsw.overridePythonAttrs (oldAttrs: {
        version = "3.38.1-r1";
        sha256 = "sha256-pbb6wCu1T1mPlgoydB1Y1AKv+kToGkdVUjiom2vTqf4=";
        checkInputs = [ ];
        checkPhase = ''
          python tests.py
        '';
      });
    });
  };
  jellyfin-mpv-shim = prev.jellyfin-mpv-shim.override {
    pywebview = prev.python3Packages.pywebview.overrideAttrs (oldAttrs: {
      doInstallCheck = false;
    });
  };
}
