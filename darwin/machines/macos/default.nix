{ lib, ... }:
{
  environment = {
    etc."per-user/pbor/ssh/authorized_keys".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTeiZ5C7zFAkxo5HGMZfxdAbDtLp6Ktv304NwrhKvkl cardno:000614470090
    '';
    variables.TERMINFO_DIRS = lib.mkForce "";
  };

  system.activationScripts.postActivation.text = ''
    mdutil -i off -d / &> /dev/null
    mdutil -E / &> /dev/null

    mkdir -p ~pbor/.ssh
    cp -f /etc/per-user/pbor/ssh/authorized_keys ~pbor/.ssh/authorized_keys
    chown pbor:staff ~pbor ~pbor/.ssh ~pbor/.ssh/authorized_keys
  '';
}

