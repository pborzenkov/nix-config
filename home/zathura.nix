{ config, pkgs, inputs, ... }:

{
  programs.zathura = {
    enable = true;
    extraConfig = builtins.readFile (config.scheme inputs.base16-zathura);
  };
}
