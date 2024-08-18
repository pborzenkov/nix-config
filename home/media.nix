{...}: {
  programs = {
    imv = {
      enable = true;
      settings = {
        binds = {
          "<Shift+greater>" = "next 1";
          "<Shift+less>" = "prev 1";
        };
      };
    };
  };
}
