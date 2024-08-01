{...}: {
  imports = [
    ./basetools
    ./foot
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
