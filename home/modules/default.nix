{...}: {
  imports = [
    ./basetools
    ./helix
    ./stylix
  ];

  config = {
    home.sessionVariables = {
      PATH = "\${HOME}/bin/:\${PATH}";
    };
  };
}
