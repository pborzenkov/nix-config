{
  inputs,
  lib,
  username,
  hostname,
  stateVersion,
  ...
}: let
  homeDirectory = "/home/${username}";
  machineConfig = ./machines + "/${hostname}";
  userConfig = ./users + "/${username}";
in {
  programs.home-manager.enable = true;

  imports =
    [
      inputs.stylix.homeManagerModules.stylix
      ./modules
    ]
    ++ lib.optional (builtins.pathExists machineConfig) machineConfig
    ++ lib.optional (builtins.pathExists userConfig) userConfig;

  home = {
    inherit username;
    inherit stateVersion;
    inherit homeDirectory;
  };
}
