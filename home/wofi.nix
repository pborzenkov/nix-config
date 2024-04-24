{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.wofi = {
    enable = true;
    settings = {
      mode = "run";
      location = "center";
      term = "${pkgs.foot}/bin/foot";
      font = "MesloLGS Nerd Font Mono 12.0";

      matching = "fuzzy";
      insensitive = "true";

      key_down = "Control_L-n";
      key_up = "Control_L-p";
    };
    style =
      ''
        window {
          font-family: "MesloLGS Nerd Font Mono";
          font-size: 12;
        }
      ''
      + builtins.readFile (config.scheme inputs.base16-wofi);
  };

  home.packages = [
    inputs.wofi-power-menu.packages."x86_64-linux".wofi-power-menu
  ];
}
