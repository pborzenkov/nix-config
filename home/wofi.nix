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
    pkgs.nur.repos.pborzenkov.wofi-power-menu
  ];

  xdg.configFile."wofi-power-menu.toml" = {
    source = (pkgs.formats.toml {}).generate "wofi-power-menu.toml" {
      wofi = {
        extra_args = "--width 20% --allow-markup --columns=1 --hide-scroll";
      };
      menu = {
        logout = {
          cmd = "loginctl terminate-session self";
          requires_confirmation = "true";
        };
        suspend.requires_confirmation = "false";
        hibernate.enabled = "false";
        windows = {
          title = "Reboot to Windows";
          cmd = "sudo systemctl reboot --boot-loader-entry auto-windows";
          icon = "";
          requires_confirmation = "true";
        };
      };
    };
  };
}
