{ ... }:
{
  environment.etc."per-user/pbor/authorized_keys".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTeiZ5C7zFAkxo5HGMZfxdAbDtLp6Ktv304NwrhKvkl cardno:000614470090
  '';
}
