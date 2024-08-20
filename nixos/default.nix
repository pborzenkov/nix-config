{
  inputs,
  lib,
  hostname,
  stateVersion,
  ...
}: let
  machineConfig = ./machines + "/${hostname}";
  machineModules = machineConfig + "/modules";
in {
  imports =
    [
      inputs.sops-nix.nixosModules.sops
      inputs.valheim-server.nixosModules.default
      ./modules
    ]
    ++ lib.optional (builtins.pathExists machineConfig) machineConfig
    ++ lib.optional (builtins.pathExists machineModules) machineModules;

  system = {
    inherit stateVersion;
  };
}
