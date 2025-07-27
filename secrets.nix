let
  # user keys
  pbor_on_metal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4QUhUEx86Z3yZA5he14ESuJoruBQBSiPSlK4Jn437M";
  users = [ pbor_on_metal ];
  # hosts
  gw = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFOcNYTmZILfBFXHR3buljmz4VTZefR5k8vsAPUCgqn";
  rock = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmMM3PtfFWmzuei80Y/xNvu990xNVx9iDCPciwxjOo2";
  metal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdcfsIA5ODSt8JqyCZUTYFndbfu4LS2/WtK5uG7PRn1";

  gw_identities = users ++ [ gw ];
  rock_identities = users ++ [ rock ];
  shared_identities = users ++ [
    rock
    metal
  ];
in
{
  # gw secrets
  "secrets/machines/gw/wireguard-key.age".publicKeys = gw_identities;

  # rock secrets
  "secrets/machines/rock/authelia-environment.age".publicKeys = rock_identities;
  "secrets/machines/rock/authelia-jwks-key.age".publicKeys = rock_identities;
  "secrets/machines/rock/namecheap-environment.age".publicKeys = rock_identities;
  "secrets/machines/rock/lldap-environment.age".publicKeys = rock_identities;
  "secrets/machines/rock/gw-proxy-environment.age".publicKeys = rock_identities;
  "secrets/machines/rock/grafana-admin-password.age".publicKeys = rock_identities;
  "secrets/machines/rock/tg-bot-alerting-environment.age".publicKeys = rock_identities;
  "secrets/machines/rock/restic-repo-password.age".publicKeys = rock_identities;
  "secrets/machines/rock/miniflux-environment.age".publicKeys = rock_identities;
  "secrets/machines/rock/valheim-environment.age".publicKeys = rock_identities;
  "secrets/machines/rock/invidious-credentials.age".publicKeys = rock_identities;
  "secrets/machines/rock/anki-sync-server-pavel-password.age".publicKeys = rock_identities;
  "secrets/machines/rock/protonvpn-amsterdam-key.age".publicKeys = rock_identities;
  "secrets/machines/rock/skyeng-push-notificator-environment.age".publicKeys = rock_identities;
  "secrets/machines/rock/fastmail-password.age".publicKeys = rock_identities;
  "secrets/machines/rock/terraform-pg-environment.age".publicKeys = rock_identities;

  # shared secrets
  "secrets/shared/listenbrainz-token.age".publicKeys = shared_identities;
  "secrets/shared/taskwarrior-sync-secret.age".publicKeys = shared_identities;
}
