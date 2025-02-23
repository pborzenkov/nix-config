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

  # rock secrets
  "machines/rock/authelia-environment.age".publicKeys = users ++ [rock];
  "machines/rock/authelia-jwks-key.age".publicKeys = users ++ [rock];
  "machines/rock/namecheap-environment.age".publicKeys = users ++ [rock];
  "machines/rock/lldap-environment.age".publicKeys = users ++ [rock];
  "machines/rock/gw-proxy-environment.age".publicKeys = users ++ [rock];
  "machines/rock/grafana-admin-password.age".publicKeys = users ++ [rock];
  "machines/rock/tg-bot-alerting-environment.age".publicKeys = users ++ [rock];
  "machines/rock/restic-repo-password.age".publicKeys = users ++ [rock];
  "machines/rock/miniflux-environment.age".publicKeys = users ++ [rock];
  "machines/rock/valheim-environment.age".publicKeys = users ++ [rock];
  "machines/rock/invidious-credentials.age".publicKeys = users ++ [rock];
  "machines/rock/anki-sync-server-pavel-password.age".publicKeys = users ++ [rock];
  "machines/rock/protonvpn-amsterdam-key.age".publicKeys = users ++ [rock];
  "machines/rock/skyeng-push-notificator-environment.age".publicKeys = users ++ [rock];
  "machines/rock/fastmail-password.age".publicKeys = users ++ [rock];
  "machines/rock/terraform-pg-environment.age".publicKeys = users ++ [rock];
  "machines/rock/shiori-environment.age".publicKeys = users ++ [rock];

  # shared secrets
  "shared/listenbrainz-token.age".publicKeys = users ++ [rock metal];
  "shared/taskwarrior-sync-secret.age".publicKeys = users ++ [rock metal];
}
