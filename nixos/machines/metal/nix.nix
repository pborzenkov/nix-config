{config, ...}: {
  nix = {
    buildMachines = [
      {
        hostName = "macos.lab.borzenkov.net";
        protocol = "ssh-ng";
        sshUser = "pbor";
        sshKey = "/root/.ssh/macos_id_ed25519";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUoxUWpZMHhwVENRbFJDRzUvZEsxcjVNeGJnWW15VitLblpUVnVMNzM0Q0cgCg==";
        system = "x86_64-darwin";
      }
    ];
    distributedBuilds = true;
  };
}
