{
  inputs,
  lib,
  hostname,
  stateVersion,
  ...
}: let
  machineConfig = ./machines + "/${hostname}";
  hardwareConfig = machineConfig + "/hardware-configuration.nix";
  machineModules = machineConfig + "/modules";
in {
  imports =
    [
      inputs.sops-nix.nixosModules.sops
      ./modules
    ]
    ++ lib.optionals (builtins.pathExists machineConfig) [machineConfig hardwareConfig]
    ++ lib.optional (builtins.pathExists machineModules) machineModules;

  system = {
    inherit stateVersion;
  };
}
