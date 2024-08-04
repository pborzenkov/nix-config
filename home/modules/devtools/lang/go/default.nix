{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.pbor.devtools.lang.go;
in {
  options = {
    pbor.devtools.lang.go.enable = (lib.mkEnableOption "Enable Go") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      go
      gopls
      golangci-lint
      golangci-lint-langserver
      delve
    ];

    home.sessionVariables = {
      GOPATH = "${config.home.homeDirectory}/.local/share/go";
    };
  };
}
