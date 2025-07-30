{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.pbor.devtools.lang.octave;
  octave-gui = pkgs.writeShellApplication {
    name = "octave-gui";
    text = ''
      exec octave --gui
    '';
  };
in
{
  options = {
    pbor.devtools.lang.octave.enable = (lib.mkEnableOption "Enable Octave") // {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    hm =
      { config, ... }:
      {
        home = {
          packages = with pkgs; [
            octaveFull
            octave-gui
          ];
        };
      };
  };
}
