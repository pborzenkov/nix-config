{
  config,
  pkgs,
  ...
}: {
  programs.taskwarrior = {
    enable = true;
    config = {
      taskd = {
        server = "taskserver.lab.borzenkov.net:53589";
        credentials = "personal/pavel/b461aae5-46ff-4657-809c-81fcbcac38dd";
        certificate = "${config.xdg.dataHome}/task/keys/public.cert";
        key = "${config.xdg.dataHome}/task/keys/private.key";
        ca = "${config.xdg.dataHome}/task/keys/ca.cert";
      };
    };
    colorTheme = "dark-gray-blue-256";
    dataLocation = "${config.xdg.dataHome}/task";
  };
  home = {
    packages = [
      pkgs.taskwarrior-tui
    ];
    shellAliases = {
      tasktui = "taskwarrior-tui";
    };
  };
}
