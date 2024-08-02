{...}: {
  imports = [
    ./basetools
    ./foot
    ./helix
    ./shell
    ./stylix
    ./wofi
    ./zathura
  ];

  config = {
    home.sessionVariables = {
      PATH = "\${HOME}/bin/:\${PATH}";
    };
  };
}
