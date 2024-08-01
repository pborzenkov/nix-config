{...}: {
  imports = [
    ./basetools
    ./foot
    ./helix
    ./shell
    ./stylix
    ./zathura
  ];

  config = {
    home.sessionVariables = {
      PATH = "\${HOME}/bin/:\${PATH}";
    };
  };
}
