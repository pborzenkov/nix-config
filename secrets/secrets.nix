let
  # user keys
  pbor_on_metal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4QUhUEx86Z3yZA5he14ESuJoruBQBSiPSlK4Jn437M";
  users = [pbor_on_metal];
  # hosts
  gw = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFOcNYTmZILfBFXHR3buljmz4VTZefR5k8vsAPUCgqn";
  rock = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmMM3PtfFWmzuei80Y/xNvu990xNVx9iDCPciwxjOo2";
  metal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdcfsIA5ODSt8JqyCZUTYFndbfu4LS2/WtK5uG7PRn1";
in {
  # gw secrets
  "machines/gw/wireguard-key.age".publicKeys = users ++ [gw];
}
