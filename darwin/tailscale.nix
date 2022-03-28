{ config, pkgs, ... }:

{
  launchd.daemons = {
    tailscaled.serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "/bin/wait4path ${pkgs.tailscale}/bin/tailscaled && ${pkgs.tailscale}/bin/tailscaled"
      ];
      RunAtLoad = true;
    };
  };

  environment.systemPackages = [
    pkgs.tailscale
  ];
}
