{...}: {
  imports = [
    ./basetools
    ./foot
    ./helix
    ./shell
    ./stylix
    ./wm
    ./wofi
    ./zathura
  ];

  config = {
    home.sessionVariables = {
      PATH = "\${HOME}/bin/:\${PATH}";
    };
  };
}
