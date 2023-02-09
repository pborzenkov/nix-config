{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
    };
    extraConfig = builtins.readFile (config.scheme inputs.base16-zathura);
  };
}
