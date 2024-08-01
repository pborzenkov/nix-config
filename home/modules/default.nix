{...}: {
  imports = [
    ./basetools
    ./helix
    ./stylix
    ./zathura
  ];

  config = {
    home.sessionVariables = {
      PATH = "\${HOME}/bin/:\${PATH}";
    };
  };
}
