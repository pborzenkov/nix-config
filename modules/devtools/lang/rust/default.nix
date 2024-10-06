{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  cfg = config.pbor.devtools.lang.rust;
in {
  options = {
    pbor.devtools.lang.rust.enable = (lib.mkEnableOption "Enable Rust") // {default = config.pbor.devtools.enable;};
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        cargo
        rustc
        rust-analyzer
        cargo-nextest
        lldb
      ];
    };
  };
}
