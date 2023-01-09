{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    cycle = true;
    font = "MesloLGS Nerd Font Mono 12.0";
    location = "center";
    terminal = "${pkgs.foot}/bin/foot";
    plugins = [pkgs.rofi-emoji];
    extraConfig = {
      modi = "run";
    };
    theme = config.scheme inputs.base16-rofi;
  };
}
