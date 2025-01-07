{
  config,
  lib,
  ...
}: let
  cfg = config.pbor.devtools.direnv;
in {
  options = {
    pbor.devtools.direnv.enable = (lib.mkEnableOption "Enable direnv") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    hm.programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };

      config = {
        disable_stdin = true;
        strict_env = false;
      };

      stdlib = ''
        : ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
                echo -n "$XDG_CACHE_HOME"/direnv/layouts/
                echo -n "$PWD" | shasum | cut -d ' ' -f 1
            )}"
        }
      '';
    };
  };
}
