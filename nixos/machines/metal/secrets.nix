{config, ...}: {
  sops.secrets = {
    fastmail = {
      mode = "0400";
      owner = config.users.users.pbor.name;
      group = config.users.users.pbor.group;
    };
    fastmail_jmap = {
      mode = "0400";
      owner = config.users.users.pbor.name;
      group = config.users.users.pbor.group;
    };
  };
}
