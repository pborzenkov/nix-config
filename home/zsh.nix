{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    defaultKeymap = "viins";

    history = {
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 10000;
      share = true;
      size = 10000;
    };

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initExtra = ''
      source ''${HOME}/.zsh/p10k-config.zsh
      source ''${HOME}/.zsh/vimode.zsh
      source ''${HOME}/.zsh/completion.zsh
      source ''${HOME}/.zsh/menuselect.zsh
    '';
  };

  home.file.zsh-p10k-config = {
    source = ./zsh/p10k-config.zsh;
    target = ".zsh/p10k-config.zsh";
  };
  home.file.zsh-vimode = {
    source = ./zsh/vimode.zsh;
    target = ".zsh/vimode.zsh";
  };
  home.file.zsh-completion = {
    source = ./zsh/completion.zsh;
    target = ".zsh/completion.zsh";
  };
  home.file.zsh-menuselect = {
    source = ./zsh/menuselect.zsh;
    target = ".zsh/menuselect.zsh";
  };
}
